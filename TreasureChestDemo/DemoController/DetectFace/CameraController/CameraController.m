//
//  CameraController.m
//  Poppy_Dev01
//
//  Created by jf on 2020/8/15.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#import "CameraPreview.h"
#import "FacePointPathLayer.h"

API_AVAILABLE(ios(11.0))
@interface CameraController () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate> {
    dispatch_queue_t sessionQueue;
    dispatch_queue_t bufferQueue;
    dispatch_queue_t metadataQueue;
}

@property(nonatomic, strong)AVCaptureSession *captureSession;
@property(nonatomic, strong)AVCaptureVideoDataOutput *videoOutput;

@property(nonatomic, strong)AVCaptureDevice *videoDevice;
@property(nonatomic, strong)AVCaptureConnection *videoConnection;

@property(nonatomic, assign)CGSize captureDeviceResolution;
@property(nonatomic, strong)UIView *rootPreview;
@property(nonatomic, strong)CameraPreview *cameraPreview;
@property(nonatomic, strong)FacePointPathLayer *overlayLayer;

// Vision requests
@property(nonatomic, strong)NSMutableArray <VNDetectFaceRectanglesRequest *> *detectionRequests;
@property(nonatomic, strong)NSMutableArray <VNTrackObjectRequest *> *trackingRequests;

@property(nonatomic, strong)VNSequenceRequestHandler *sequenceRequestHandler;

@end

@implementation CameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    sessionQueue = dispatch_queue_create("com.yinliqu.camera.session", DISPATCH_QUEUE_SERIAL);
    bufferQueue = dispatch_queue_create("com.yinliqu.camera.buffer", DISPATCH_QUEUE_SERIAL);
    metadataQueue = dispatch_queue_create("com.yinliqu.camera.metadata", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(bufferQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    [self prepareRuning];

    [self prepareVisionRequest];//准备人脸检测和跟踪。
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self teardownAVCapture];
}

- (void)teardownAVCapture {
    [self.captureSession stopRunning];
    [self.cameraPreview removeFromSuperview];
    self.cameraPreview = nil;
    
    self.videoOutput = nil;
    bufferQueue = nil;
    sessionQueue = nil;
    metadataQueue = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_captureSession];//可能不需要
}

#pragma mark - < camera >
- (void)prepareRuning {
    dispatch_async(sessionQueue, ^{
        self.captureSession = [[AVCaptureSession alloc]init];
        [self captureSessionNotification];  //监听状态
        
        [self.captureSession beginConfiguration];
        [self setupSession];
        [self.captureSession commitConfiguration];
        [self startRuning];
        
        [self initView];
    });
}

- (void)startRuning {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self.captureSession startRunning];
        }];
    }else {
        [self.captureSession startRunning];
    }
}

- (void)setupSession {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    self.videoDevice = videoDevice;
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc]initWithDevice:videoDevice error:nil];
    if ([_captureSession canAddInput:videoIn]) {
        [_captureSession addInput:videoIn];
    }
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc]init];
    videoOut.alwaysDiscardsLateVideoFrames = YES;//如果录制的话，还是不希望有丢帧的情况(可以改成NO)。
    [videoOut setSampleBufferDelegate:self queue:bufferQueue];
    videoOut.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    if ([_captureSession canAddOutput:videoOut]) {
        [_captureSession addOutput:videoOut];
    }
    
    ///看需要，目前可能可以不用这个
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
    if ([_captureSession canAddOutput:captureMetadataOutput]) {
        [_captureSession addOutput:captureMetadataOutput];
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
        [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    }
    
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    
    //这里的分辨率可以考虑根据设备来设置合适的,比如：AVCaptureSessionPreset1280x720
//    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
//        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
//    }else {
//        _captureSession.sessionPreset = AVCaptureSessionPresetLow;//先用这个低分辨率做算法相关。AVCaptureSessionPresetMedium
//        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
//    }
    
    [self setResolution32BGRAFormat:videoDevice];
//    self.captureDeviceResolution = CGSizeMake(640, 480);
    
    /*
    * CMTime的scale，默认给1000。
    CMTime定义是一个C语言的结构体，CMTime是以分数的形式表示时间，value表示分子，timescale表示分母。
    但是由于浮点型数据计算很容易导致精度的丢失，在一些要求高精度的应用场景显然不适合，于是苹果在Core Media框架中定义了CMTime数据类型作为时间的格式
    */
    int frameRate = 30;
    CMTime frameDuration = CMTimeMake(1000, 1000*frameRate);
    NSError *error = nil;
    if ([videoDevice lockForConfiguration:&error]) {
        videoDevice.activeVideoMaxFrameDuration = frameDuration;
        videoDevice.activeVideoMinFrameDuration = frameDuration;
        [videoDevice unlockForConfiguration];
    }else {
        NSLog(@"videoDevice lockForConfiguration error：%@",error);
    }
    
    
    [videoOut recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    
    NSLog(@"videoOrientation %ld",(long)_videoConnection.videoOrientation);
    //    self.videoOrientaiton = _videoConnection.videoOrientation;
}

- (void)captureSessionNotification {
    //考虑UIApplicationWillEnterForegroundNotification
//    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:nil object:_captureSession] subscribeNext:^(NSNotification * _Nullable x) {
//        @strongify(self);
        if ([x.name isEqualToString:AVCaptureSessionWasInterruptedNotification]) {
                NSLog(@"session interrupted");
        }else if ([x.name isEqualToString:AVCaptureSessionInterruptionEndedNotification]) {
                NSLog(@"session interruption ended");
        }else if ([x.name isEqualToString:AVCaptureSessionRuntimeErrorNotification]) {
                NSLog(@"session runtime error");
        }else if ([x.name isEqualToString:AVCaptureSessionDidStartRunningNotification]) {
                NSLog(@"session started running");
        }else if ([x.name isEqualToString:AVCaptureSessionDidStopRunningNotification]) {
                NSLog(@"session stopped running");
        }
    }];
}

#pragma mark - < delegate >
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFTimeInterval startTime = CACurrentMediaTime();
    
    NSMutableDictionary *requestHandlerOptions = [NSMutableDictionary dictionaryWithCapacity:0];
    CFTypeRef cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil);
    if (cameraIntrinsicData != nil) {
        requestHandlerOptions[@"cameraIntrinsics"] = CFBridgingRelease(cameraIntrinsicData);
    }
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return;
    }
    
    CGImagePropertyOrientation exifOrientation = [self exifOrientationForCurrentDeviceOrientation];
    NSMutableArray <VNTrackObjectRequest *> *requests = self.trackingRequests;
    
    if (requests.count == 0) {
        // 未检测到跟踪对象，执行初始检测
        VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc]initWithCVPixelBuffer:pixelBuffer
                                                                                             orientation:exifOrientation
                                                                                                 options:requestHandlerOptions];
        if (self.detectionRequests.count == 0) {
            return;
        }
        NSError *error = nil;
        [imageRequestHandler performRequests:self.detectionRequests error:&error];
        if (error) {
            NSLog(@"Failed to perform FaceRectangleRequest: %@", error);
        }
        return;
    }
    
    // 处理单一图片使用 VNImageRequestHandler，处理图片序列使用 VNSequenceRequestHandler
    // 如果我们使用的是 VNImageRequestHandler，那么在初始化时就提供需要处理的图片，初始化以后使用 perform(_:) 方法执行我们的 Request
    NSError *error = nil;
    [self.sequenceRequestHandler performRequests:requests onCVPixelBuffer:pixelBuffer error:&error];//这里是追踪人脸。
    if (error) {
        NSLog(@"Failed to perform SequenceRequest: %@", error);
    }
    
    // --------------设置下一轮跟踪。
    NSMutableArray <VNTrackObjectRequest *> *newTrackingRequests = [NSMutableArray arrayWithCapacity:0];
    for (VNTrackObjectRequest *trackingRequest in requests) {
        
        if (trackingRequest.results.count == 0) {
            return;
        }
        if (![trackingRequest.results[0] isKindOfClass:[VNDetectedObjectObservation class]]) {
            return;
        }
        VNDetectedObjectObservation *observation = trackingRequest.results[0];
        if (!trackingRequest.isLastFrame) {
            if (observation.confidence > 0.3) {//跟踪一段时间后，置信值会降低。
                trackingRequest.inputObservation = observation;
            }else {
                [trackingRequest setLastFrame:true];
            }
            [newTrackingRequests addObject:trackingRequest];
        }
    }
    self.trackingRequests = newTrackingRequests;
    
    if (newTrackingRequests.count == 0) {
        return;// 跟踪结果为空
    }
    
    // --------------在检测到的人脸中，进行人脸landmark跟踪
    NSMutableArray <VNDetectFaceLandmarksRequest *> *faceLandmarkRequests = [NSMutableArray arrayWithCapacity:0];
    
    // 对被跟踪的人脸进行landmark检测
    for (VNTrackObjectRequest *trackingRequest in newTrackingRequests) {
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新UI
                NSLog(@"更新UI");
//                NSLog(@"results: %f %@",results[0].boundingBox.size.width,results[0].landmarks.leftEye);
                [self drawFaceObservations:results];
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
        
        VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer orientation:exifOrientation options:requestHandlerOptions];
        NSError *error = nil;
        [imageRequestHandler performRequests:faceLandmarkRequests error:&error];
        if (error) {
            NSLog(@"Failed to perform FaceLandmarkRequest: %@", error);
        }
    }
    CFTimeInterval inferenceTime = (CACurrentMediaTime() - startTime) * 1000;NSLog(@"duration: %f",inferenceTime);
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
}

#pragma mark - < private >
- (void)prepareVisionRequest {
    NSMutableArray <VNTrackObjectRequest *> *requests = [NSMutableArray arrayWithCapacity:0];
    
    //这里会被回调，在执行这个函数后：imageRequestHandler.perform(self.detectionRequests)
    VNDetectFaceRectanglesRequest *faceDetectionRequest = [[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        NSLog(@"prepareVisionRequest ：人脸检测");//尝试改成其他方案寻找人脸框，然后用这个框生成：VNFaceObservation。（不过也只是初始更快了，中间的跟踪还是一样的速度，可以作为一个优化项）
        if (error) {
            NSLog(@"FaceDetection error: %@",error.description);
        }
        //人脸位置检测
        VNDetectFaceRectanglesRequest *faceDetectionRequest = (VNDetectFaceRectanglesRequest *)request;
        NSArray <VNFaceObservation *>*results = faceDetectionRequest.results;
        if (faceDetectionRequest == nil || results.count == 0) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 将观察结果添加到跟踪列表
            for (VNFaceObservation *observation in results) {
                VNTrackObjectRequest *faceTrackingRequest = [[VNTrackObjectRequest alloc]initWithDetectedObjectObservation:observation];
                [requests addObject:faceTrackingRequest];
            }
            self.trackingRequests = requests;
        });
    }];
    
    
    // 开始检测。找到脸，然后跟踪它。
    self.detectionRequests = [NSMutableArray arrayWithObject:faceDetectionRequest];
    self.sequenceRequestHandler = [[VNSequenceRequestHandler alloc]init];
}

//更新特征点的overlayer
- (void)drawFaceObservations:(NSArray <VNFaceObservation *> *)faceObservations {
    CGRect videoPreviewRect = [self.cameraPreview.previewLayer rectForMetadataOutputRectOfInterest:CGRectMake(0, 0, 1, 1)];
    [self.overlayLayer refreshWithLandmarkResults:faceObservations videoPreviewRect:videoPreviewRect];
}

#pragma mark - < init view >
- (void)initView {
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rootPreview = [[UIView alloc]init];
        weakSelf.rootPreview.frame = weakSelf.view.bounds;
        [weakSelf.view addSubview:weakSelf.rootPreview];
        
        weakSelf.cameraPreview = [[CameraPreview alloc]init];
        weakSelf.cameraPreview.frame = weakSelf.view.bounds;
        [weakSelf.rootPreview addSubview:weakSelf.cameraPreview];

        [weakSelf configPreviewLayer:weakSelf.cameraPreview];
        [weakSelf setupVisionDrawingLayers];//准备绘制的layer
    });
}

- (void)configPreviewLayer:(CameraPreview *)preview {
    preview.previewLayer.session = _captureSession;
    preview.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    //初始时，相机会有个很突兀的填充动画，这里把隐式动画禁掉
    preview.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [CATransaction commit];
}

- (void)setupVisionDrawingLayers {
    CGRect captureDeviceBounds = CGRectMake(0, 0, self.captureDeviceResolution.width, self.captureDeviceResolution.height);
    self.overlayLayer = [[FacePointPathLayer alloc] initWithDeviceResolution:self.captureDeviceResolution];
    self.overlayLayer.bounds = captureDeviceBounds;
    [self.rootPreview.layer addSublayer:self.overlayLayer];
}

#pragma mark - < helper >
- (CGImagePropertyOrientation)exifOrientationForCurrentDeviceOrientation {
    return [self exifOrientationForDeviceOrientation:UIDevice.currentDevice.orientation];
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

///这个没什么用，是demo为了获取最大的分辨率的一个方法。这里改造了，直接赋值AVCaptureSessionPreset640x480里的分辨率。
- (void)setResolution32BGRAFormat:(AVCaptureDevice *)device {
    AVCaptureDeviceFormat *highestResolutionFormat;
    CMVideoDimensions highestResolutionDimensions;
    for (AVCaptureDeviceFormat *format in device.formats) {
        CMFormatDescriptionRef deviceFormatDescription = format.formatDescription;
        //kCVPixelFormatType_32BGRA与上面的videoOut.videoSettings一致
        if (CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            CMVideoDimensions candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription);
            if (candidateDimensions.width > highestResolutionDimensions.width) {
                highestResolutionFormat = format;
                highestResolutionDimensions = candidateDimensions;
            }
        }
    }
    
    if (highestResolutionFormat != nil) {
        self.captureDeviceResolution = CGSizeMake(highestResolutionDimensions.width, highestResolutionDimensions.height);
    }
}

@end
