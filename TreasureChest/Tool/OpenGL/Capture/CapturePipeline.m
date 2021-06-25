//
//  CapturePipeline.m
//  Poppy_Dev01
//
//  Created by jf on 2020/10/20.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "CapturePipeline.h"

@interface CapturePipeline () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate> {
    dispatch_queue_t bufferQueue;
}

@end

@implementation CapturePipeline

- (instancetype)init {
    if(self == [super init]){
        NSLog(@"capture start %p",self);
    }
    return self;
}

#pragma mark - < public >
- (void)prepareRunning {
    if (self.captureSession.isRunning) {
        return;
    }
    
    bufferQueue = dispatch_queue_create("com.yinliqu.camera.didOutputSampleBuffer", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(bufferQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    self.captureSession = [[AVCaptureSession alloc]init];
    [self captureSessionNotification];  //监听状态
    
    [self.captureSession beginConfiguration];
    [self setupSession];
    [self.captureSession commitConfiguration];
}

- (void)startRunning {
    if (self.captureSession.isRunning) {
        return;
    }
    
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self.captureSession startRunning];
        }];
    }else {
        [self.captureSession startRunning];
    }
}

- (void)pauseRunning {
    NSLog(@"pauseRunning");
    [self.captureSession stopRunning];
}

- (void)stopRunning {
    NSLog(@"stopRunning");
//    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
        [self teardownAVCapture];
//    }
}

- (void)capturePhoto {
    AVCapturePhotoSettings *set = [AVCapturePhotoSettings photoSettings];
    [self.photoOutput capturePhotoWithSettings:set delegate:self];
}

#pragma mark - < camera >
- (void)setupSession {
    AVCaptureDevicePosition position = self.devicePostion == 0 ? AVCaptureDevicePositionFront : self.devicePostion;
    AVCaptureSessionPreset preset = self.sessionPreset == nil ? AVCaptureSessionPreset640x480 : self.sessionPreset;
    AVCaptureVideoOrientation oritentation = self.orientation == 0 ? AVCaptureVideoOrientationLandscapeRight : self.orientation;
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
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
    
    //静态图
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([_captureSession canAddOutput:self.photoOutput]) {
        [_captureSession addOutput:self.photoOutput];
    }
    [self.photoOutput.connections.lastObject setVideoOrientation:oritentation];

    
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    
    //这里的分辨率可以考虑根据设备来设置合适的,比如：AVCaptureSessionPreset1280x720、AVCaptureSessionPreset640x480
    _captureSession.sessionPreset = preset;
    
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
}

- (void)captureSessionNotification {
    //考虑UIApplicationWillEnterForegroundNotification
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:nil object:_captureSession] subscribeNext:^(NSNotification * _Nullable x) {
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

- (void)teardownAVCapture {
    self.videoOutput = nil;
    self.captureSession = nil;
    bufferQueue = nil;
}

#pragma mark - < delegate >
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"capture %p",self);
    if ( connection == _videoConnection ) {
        if ([self.delegate respondsToSelector:@selector(capturePipelineDidOutputSampleBuffer:)]) {
            [self.delegate capturePipelineDidOutputSampleBuffer:sampleBuffer];
        }
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(capturePipelineDidCapturePhoto:)]) {
            [self.delegate capturePipelineDidCapturePhoto:photo];
        }
    }
}

@end

