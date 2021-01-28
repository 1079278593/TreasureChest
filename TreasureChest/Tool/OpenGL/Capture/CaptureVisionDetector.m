//
//  CaptureVisionDetector.m
//  Poppy_Dev01
//
//  Created by jf on 2020/12/23.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "CaptureVisionDetector.h"

@interface CaptureVisionDetector ()

@property(nonatomic, strong)NSMutableArray <VNDetectFaceRectanglesRequest *> *detectionRequests;
@property(nonatomic, strong)NSMutableArray <VNTrackObjectRequest *> *trackingRequests;

//处理与多个图像序列有关的图像分析请求的对象。
@property(nonatomic, strong)VNSequenceRequestHandler *sequenceRequestHandler;

@end

@implementation CaptureVisionDetector

#pragma mark - < public >

/*
 * face: detect and tracking
 * VNFaceObservation通过图像分析请求监测脸部及面部特征信息。
 */
- (void)prepareVisionRequest {
    NSMutableArray <VNTrackObjectRequest *> *requests = [NSMutableArray arrayWithCapacity:0];
    
    //这里会被回调，在执行这个函数后：imageRequestHandler.perform(self.detectionRequests)
    VNDetectFaceRectanglesRequest *faceDetectionRequest = [[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        //尝试改成其他方案寻找人脸框，然后用这个框生成：VNFaceObservation。（不过也只是初始更快了，中间的跟踪还是一样的速度，可以作为一个优化项）
//        NSLog(@"captureVision prepareVisionRequest ：人脸检测 ,request数量：%lu detectionRequests:%lu",request.results.count,self.detectionRequests.count);
        if (error) {
            NSLog(@"FaceDetection error: %@",error.description);
        }
        //人脸位置检测：数组results代表检测到多少张人脸
        VNDetectFaceRectanglesRequest *faceDetectionRequest = (VNDetectFaceRectanglesRequest *)request;
        NSArray <VNFaceObservation *>*results = faceDetectionRequest.results;
        if (faceDetectionRequest == nil || results.count == 0) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 将观察结果添加到跟踪列表
            for (VNFaceObservation *observation in results) {
                //VNTrackObjectRequest:图像分析请求，跟踪先前识别的任意对象在多个图像或视频帧之间的移动。
                VNTrackObjectRequest *faceTrackingRequest = [[VNTrackObjectRequest alloc]initWithDetectedObjectObservation:observation];
                [requests addObject:faceTrackingRequest];
            }
            self.trackingRequests = requests;
        });
    }];

    self.detectionRequests = [NSMutableArray arrayWithObject:faceDetectionRequest];
    self.sequenceRequestHandler = [[VNSequenceRequestHandler alloc]init];
}

- (void)visionRequestFromPixelBuffer:(CVImageBufferRef)pixelBuffer {
    
    CGImagePropertyOrientation exifOrientation = [self exifOrientationForCurrentDeviceOrientation];
    if (exifOrientation != kCGImagePropertyOrientationLeftMirrored) {
        //不是竖直方向，就不识别
        if ([self.delegate respondsToSelector:@selector(visionDetectorResult:)]) {
            [self.delegate visionDetectorResult:nil];//显示雪花
        }
        return;
    }
    
    
    NSMutableArray <VNTrackObjectRequest *> *requests = self.trackingRequests;
    
//    NSLog(@"captureVision newTrackingRequests count: %lu",(unsigned long)requests.count);
    if (requests.count >= 2) {
        NSLog(@"captureVision newTrackingRequests 超过");
        VNTrackObjectRequest *lastTrack = requests.lastObject;
        requests = [NSMutableArray arrayWithObject:lastTrack];
        /**
         如果超过一定数量会报错（比如iPhone11的数量是727个，或者373。总结就是数量估计要控制在1个），报错如下：
         {NSLocalizedDescription=Internal error: Exceeded maximum allowed number of Trackers for a tracker type: VNObjectTrackerRevision2Type}
         */
    }
    
    
    // --------------1.判断是否需要检测
    if (requests.count == 0) { // 未检测到跟踪对象，执行初始检测
        VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc]initWithCVPixelBuffer:pixelBuffer orientation:exifOrientation options:[NSDictionary new]];
        if (self.detectionRequests.count == 0) { return; }
        if ([self.delegate respondsToSelector:@selector(visionDetectorResult:)]) {
            [self.delegate visionDetectorResult:nil];//显示雪花
        }
        NSError *error = nil;
        [imageRequestHandler performRequests:self.detectionRequests error:&error];
        if (error) { NSLog(@"Failed to perform FaceRectangleRequest: %@", error); }
        return;
    }
    
    /*
     * 这里是追踪人脸。
     * 处理单一图片使用 VNImageRequestHandler，处理图片序列使用 VNSequenceRequestHandler
     * VNSequenceRequestHandler执行performRequests后，将结果写入VNTrackObjectRequest的results属性中
     */
    NSError *error = nil;
    [self.sequenceRequestHandler performRequests:requests onCVPixelBuffer:pixelBuffer orientation:exifOrientation error:&error];
    if (error) { NSLog(@"Failed to perform SequenceRequest: %@", error); }
    
    // --------------2.设置下一轮跟踪。
    NSMutableArray <VNTrackObjectRequest *> *newTrackingRequests = [self getNextTrackingRequest:requests];
    self.trackingRequests = newTrackingRequests;
    if (newTrackingRequests.count == 0) {
        if ([self.delegate respondsToSelector:@selector(visionDetectorResult:)]) {
            [self.delegate visionDetectorResult:nil];//显示雪花
        }
        return;
    }// 跟踪结果为空
    
    // --------------3.在跟踪的人脸中，进行人脸landmark检测
    [self faceLandmarkRequestFromTrackedRequest:newTrackingRequests pixelBuffer:pixelBuffer];
}

- (void)stopDetect {
    self.detectionRequests = nil;
    self.trackingRequests = nil;
    self.sequenceRequestHandler = nil;
}

#pragma mark - < private >
- (NSMutableArray <VNTrackObjectRequest *> *)getNextTrackingRequest:(NSMutableArray <VNTrackObjectRequest *> *)requests {
    NSMutableArray <VNTrackObjectRequest *> *newTrackingRequests = [NSMutableArray arrayWithCapacity:0];
    for (VNTrackObjectRequest *trackingRequest in requests) {
        if (trackingRequest.results.count == 0) { return nil; }
        if (![trackingRequest.results[0] isKindOfClass:[VNDetectedObjectObservation class]]) { return nil; }
        
        VNDetectedObjectObservation *observation = trackingRequest.results[0];
        if (!trackingRequest.isLastFrame) {
//            NSLog(@"observation.confidence：%f",observation.confidence);
            if (observation.confidence > 0.99) {//一般是0.999，边缘区会降下来，用手遮挡的比较严重会降下来。只要小于0.99，就‘雪花’屏
                trackingRequest.inputObservation = observation;
            }else {
                [trackingRequest setLastFrame:true];
            }
            [newTrackingRequests addObject:trackingRequest];
//            NSLog(@"observation.boundingBox %@",NSStringFromCGRect(observation.boundingBox));
        }
    }
    return newTrackingRequests;
}

- (void)faceLandmarkRequestFromTrackedRequest:(NSMutableArray <VNTrackObjectRequest *> *)trackingRequests pixelBuffer:(CVImageBufferRef)pixelBuffer {
    CGImagePropertyOrientation exifOrientation = [self exifOrientationForCurrentDeviceOrientation];
    NSMutableArray <VNDetectFaceLandmarksRequest *> *faceLandmarkRequests = [NSMutableArray arrayWithCapacity:0];
    
    // 对被跟踪的人脸进行landmark检测
    for (VNTrackObjectRequest *trackingRequest in trackingRequests) {
        //创建request，等待perform
        VNDetectFaceLandmarksRequest *faceLandmarksRequest = [[VNDetectFaceLandmarksRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            if (error) {
                NSLog(@"FaceLandmarks error: %@",error.description);
            }
            VNDetectFaceLandmarksRequest *landmarksRequest = (VNDetectFaceLandmarksRequest *)request;
            NSArray <VNFaceObservation *> *results = landmarksRequest.results;
            if (landmarksRequest == nil || results.count == 0) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{//这里拿到点数据，可以进行绘制
                //这里只取第一个脸
                VNFaceObservation *targetFace = results[0];
                //sNSLog(@"脸特征点数量：%d",targetFace.landmarks.allPoints.pointCount);
                //将识别的数据传出去
                if ([self.delegate respondsToSelector:@selector(visionDetectorResult:)]) {
                    [self.delegate visionDetectorResult:targetFace];
                }
            });
        }];
        
        NSArray *trackingResults = trackingRequest.results;
        if (trackingResults.count == 0) {
            return;
        }
        if (![trackingResults[0] isKindOfClass:[VNDetectedObjectObservation class]]) {
            return;
        }
        
        VNDetectedObjectObservation *observation = trackingResults[0];
        VNFaceObservation *faceObservation = [VNFaceObservation observationWithBoundingBox:observation.boundingBox];
        faceLandmarksRequest.inputFaceObservations = @[faceObservation];
        
        // 继续追踪检测到的面部标志。
        [faceLandmarkRequests addObject:faceLandmarksRequest];
        
        VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer orientation:exifOrientation options:[NSDictionary new]];
        NSError *error = nil;
        [imageRequestHandler performRequests:faceLandmarkRequests error:&error];
        if (error) {
            NSLog(@"Failed to perform FaceLandmarkRequest: %@", error);
        }
        imageRequestHandler = nil;
    }
}

#pragma mark - < helper >
- (CGImagePropertyOrientation)exifOrientationForCurrentDeviceOrientation {
    //需要外界传入方向
    return [self exifOrientationForDeviceOrientation:self.deviceOrientation];
}

- (CGImagePropertyOrientation)exifOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
        {
            return kCGImagePropertyOrientationRightMirrored;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            return kCGImagePropertyOrientationDownMirrored;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            return kCGImagePropertyOrientationUpMirrored;
        }
            break;
        default:
            return kCGImagePropertyOrientationLeftMirrored;
            break;
    }
}

@end
