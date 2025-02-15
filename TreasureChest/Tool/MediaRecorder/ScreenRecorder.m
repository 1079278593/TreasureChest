//
//  ScreenRecorder.m
//  helloLaihua
//
//  Created by 小明 on 2017/8/31.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import "ScreenRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface ScreenRecorder ()

@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
@property (nonatomic, strong) NSDictionary *outputBufferPoolAuxAttributes;

@property (nonatomic, retain) dispatch_queue_t render_queue;
@property (nonatomic, retain) dispatch_queue_t append_pixelBuffer_queue;
@property (nonatomic, retain) dispatch_semaphore_t frameRenderingSemaphore;
@property (nonatomic, retain) dispatch_semaphore_t pixelAppendSemaphore;

@property (nonatomic, assign) CGColorSpaceRef rgbColorSpace;
@property (nonatomic, assign) CVPixelBufferPoolRef outputBufferPool;

@property (nonatomic, strong) CADisplayLink *displayLink;
//@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPauseRecording;

//1. recorder use frameRate
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGFloat scale;

//2. recorder use time
@property (nonatomic) CFTimeInterval previousStamp;
@property (nonatomic) CFTimeInterval validStamp;

@end

@implementation ScreenRecorder

#pragma mark - Life Cycle
+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
         _viewSize = [UIApplication sharedApplication].delegate.window.bounds.size;//设置视频尺寸
        _scale = [UIScreen mainScreen].scale;
        _scale = 1.5;
        // record half size resolution for retina iPads
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && _scale > 1) {
            _scale = 1.0;
        }
        
        //semaphore set
        _append_pixelBuffer_queue = dispatch_queue_create("VideoRecorder_appendQueue", DISPATCH_QUEUE_SERIAL);
        _render_queue = dispatch_queue_create("VideoRecorder_renderQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_render_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        _pixelAppendSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Video Record Events
- (void)startRecording {
    if (_isRecording) {
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.videoPath]) {
        if (![fm removeItemAtPath:self.videoPath error:nil]) {
            NSLog(@"remove screenVideo failed.");
        }
    }
    
    if (self.recorderView.frame.size.width > 0) {
        _viewSize = self.recorderView.frame.size;
    }
    
    [self recorderAttributeSetting];
    
    _isRecording = (self.videoWriter.status == AVAssetWriterStatusWriting);
    
    //displaylink方式
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(recordRunloop)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.preferredFramesPerSecond = frameRate;
    
    //NSOperationQueue方式
//    if (!self.queue) {
//        //1.创建队列
//        self.queue = [[NSOperationQueue alloc] init];
//    }
//    
//    // 2.创建操作：使用 NSInvocationOperation 创建操作
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(recordRunloop) object:nil];
//    [self.queue addOperation:operation];

}

- (void)stopRecording {
    if (!_isRecording) {
        return;
    }
    [self recordFinish];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)pauseRecording {
    [self pauseLayer:self.recorderView.layer];
    _isPauseRecording = YES;
}

- (void)resumeRecording {
    [self resumeLayer:self.recorderView.layer];
    _isPauseRecording = NO;
}

- (void)forceStopRecording {
    NSLog(@"forceStopRecording");
    [self resetRecorder];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [_videoWriterInput markAsFinished];
    [_videoWriter finishWritingWithCompletionHandler:^{
        
    }];
}
#pragma mark - layer animation pause/resume
- (void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    NSLog(@"暂停layer动画，paused time:%f", pausedTime);
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续layer上面的动画
- (void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
    NSLog(@"pause time:%f", pausedTime);
    NSLog(@"恢复layer动画,begin time:%f", timeSincePause);
}

#pragma mark - recording
- (void)recordRunloop {
    
    if (!self.isRecording) {
        NSLog(@"视频已经结束录制");
        return;
    }
    
    if (self.isPauseRecording) {
        //如果是暂停中，需要实时得到最新的时间戳。
        self.previousStamp = self.displayLink.timestamp;
        return;
    }
    
    if (dispatch_semaphore_wait(_frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    
    //将当期帧数传递出去
    if (self.frameCountBlock) {
        self.frameCountBlock(self.frameCount);
    }
    
    @weakify(self);
    // throttle the number of frames to prevent meltdown
    // technique gleaned from Brad Larson's answer here: http://stackoverflow.com/a/5956119
    dispatch_async(_render_queue, ^{
        @strongify(self);
        if (![self.videoWriterInput isReadyForMoreMediaData]) return;
        
        CMTime time;
        if (isRecordFramRate) {
            //按照帧数:(第几帧,每秒帧数)
            self.frameCount++;
            time = CMTimeMake(self.frameCount, (int32_t) frameRate);
            NSLog(@"frame count:%ld", (long) self.frameCount);
            NSLog(@"video duration:%f", (self.frameCount / (float) frameRate));
        } else {
            //按照时间:(第几秒,时间尺度：首选的时间尺度"每秒的帧数")！
            if (self.previousStamp == 0) {
                self.previousStamp = self.displayLink.timestamp;
            } else {
                self.validStamp += self.displayLink.timestamp - self.previousStamp;
                self.previousStamp = self.displayLink.timestamp;
            }
            time = CMTimeMakeWithSeconds(self.validStamp, 1000);
            NSLog(@"validStamp:%f", self.validStamp);
            NSLog(@"displayLink timestamp:%f", self.displayLink.timestamp);
        }
        
        CVPixelBufferRef pixelBuffer = NULL;
        CGContextRef bitmapContext = [self bitmapContextFromBuffer:&pixelBuffer];
        // draw each window into the context (other windows include UIKeyboard, UIAlert)
        // FIX: UIKeyboard is currently only rendered correctly in portrait orientation
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIGraphicsPushContext(bitmapContext);
            {
                //填充背景色
                CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
                CGContextFillRect(bitmapContext, CGRectMake(0, 0, self.viewSize.width, self.viewSize.height));
                
                CGFloat progressTime = self.validStamp;
                if (isRecordFramRate) {
                    progressTime = (CGFloat) self.frameCount / frameRate;
                }
                
                [self.recorderView.layer.presentationLayer renderInContext:bitmapContext];
            }
            
            UIGraphicsPopContext();
        });
        
        if (dispatch_semaphore_wait(self.pixelAppendSemaphore, DISPATCH_TIME_NOW) == 0) {
            dispatch_async(self.append_pixelBuffer_queue, ^{
                if (self.isRecording && self.videoWriter) {
                    //想办法直接给数据，减少render
                    BOOL success = [self.avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                    if (!success) {
                        NSLog(@"Warning: Unable to write buffer to video");
                    }
                    CGContextRelease(bitmapContext);
                    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                    CVPixelBufferRelease(pixelBuffer);
                    dispatch_semaphore_signal(self.pixelAppendSemaphore);
                }
            });
        } else {
            CGContextRelease(bitmapContext);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            CVPixelBufferRelease(pixelBuffer);
        }
        dispatch_semaphore_signal(self.frameRenderingSemaphore);
    });
}

- (void)recordFinish;
{
    NSLog(@"recordFinishWithSession");
    @weakify(self)
    dispatch_async(_render_queue, ^{
        @strongify(self)
        dispatch_sync(self.append_pixelBuffer_queue, ^{
            [self.videoWriterInput markAsFinished];
            [self.videoWriter finishWritingWithCompletionHandler:^{
                if (self.videoURL) {
                    [self resetRecorder];
                    self.finishBlock(self.videoPath);
                }
            }];
        });
    });
}

//- (CGContextRef)pixelBufferAfterRender {
//    CVPixelBufferRef pixelBuffer = NULL;
//    CGContextRef bitmapContext = [self bitmapContextFromBuffer:&pixelBuffer];
//    // draw each window into the context (other windows include UIKeyboard, UIAlert)
//    // FIX: UIKeyboard is currently only rendered correctly in portrait orientation
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        UIGraphicsPushContext(bitmapContext);
//        {
//            //填充背景色
//            CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
//            CGContextFillRect(bitmapContext, CGRectMake(0, 0, self.viewSize.width, self.viewSize.height));
//            
//            CGFloat progressTime = self.validStamp;
//            if (isRecordFramRate) {
//                progressTime = (CGFloat) self.frameCount / frameRate;
//            }
//            
//            [self.recorderView.layer.presentationLayer renderInContext:bitmapContext];
//        }
//        
//        UIGraphicsPopContext();
//    });
//    
//    return bitmapContext;
//}

- (CGContextRef)bitmapContextFromBuffer:(CVPixelBufferRef *)pixelBuffer {
    
    CVPixelBufferPoolCreatePixelBuffer(NULL, _outputBufferPool, pixelBuffer);
    CVPixelBufferLockBaseAddress(*pixelBuffer, 0);
    
    CGContextRef bitmapContext = NULL;
    
    bitmapContext = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(*pixelBuffer),
                                          CVPixelBufferGetWidth(*pixelBuffer),
                                          CVPixelBufferGetHeight(*pixelBuffer),
                                          8, CVPixelBufferGetBytesPerRow(*pixelBuffer), _rgbColorSpace,
                                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextScaleCTM(bitmapContext, _scale, _scale);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, _viewSize.height);
    
    CGContextConcatCTM(bitmapContext, flipVertical);
    
    return bitmapContext;
}

#pragma mark - Private Methods
///recorder的初始设置
- (void)recorderAttributeSetting {
    
    NSLog(@"setUpWriter");
    _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    NSDictionary *bufferAttributes = @{(id) kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                       (id) kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                       (id) kCVPixelBufferWidthKey : @(_viewSize.width * _scale),
                                       (id) kCVPixelBufferHeightKey : @(_viewSize.height * _scale),
                                       (id) kCVPixelBufferBytesPerRowAlignmentKey : @(_viewSize.width * _scale * 4)
                                       };
    
    _outputBufferPool = NULL;
    CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(bufferAttributes), &_outputBufferPool);
    
    //必须删除了这个文件，如果存在这个文件，无法开始新的录制
    [self removeVideoFromPath:self.videoPath];
    
    NSParameterAssert(self.videoWriter);
    
    NSInteger pixelNumber = _viewSize.width * _viewSize.height * _scale;
    NSDictionary *videoCompression = @{ AVVideoAverageBitRateKey : @(pixelNumber * 11.4) }; //11.4视频平均压缩率，值10.1相当于AVCaptureSessionPresetHigh，数值越大，显示越精细，当前7.5
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : [NSNumber numberWithInt:_viewSize.width * _scale],
                                    AVVideoHeightKey : [NSNumber numberWithInt:_viewSize.height * _scale],
                                    AVVideoCompressionPropertiesKey : videoCompression};
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSParameterAssert(_videoWriterInput);
    
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    _videoWriterInput.transform = [self transformFromOrientation];
    
    _avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:nil];
    
    [self.videoWriter addInput:_videoWriterInput];
    
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
}

///根据device的orientation返回transform，设置视频方向
- (CGAffineTransform)transformFromOrientation {
    CGAffineTransform videoTransform;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            videoTransform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoTransform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            videoTransform = CGAffineTransformIdentity;
    }
    if (self.expireDirection) {
        videoTransform = CGAffineTransformIdentity;
    }
    //    NSLog(@"视频录制方向%d",[UIDevice currentDevice].orientation);
    return videoTransform;
}

///根据path删除视频文件
- (void)removeVideoFromPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            NSLog(@"Could not delete old recording:%@", [error localizedDescription]);
        }
    }
}

///根据path，返回文件大小
- (long long)fileSizeFromPath:(NSString *)path {
    NSFileManager *fileMananger = [NSFileManager defaultManager];
    if ([fileMananger fileExistsAtPath:path]) {
        NSDictionary *dic = [fileMananger attributesOfItemAtPath:path error:nil];
        return [dic[ @"NSFileSize" ] longLongValue];
        //  return [[fileMananger attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    
    return 0;
}

///重置recorder
- (void)resetRecorder {
    NSLog(@"resetRecorder"); //
    self.avAdaptor = nil;
    self.videoWriterInput = nil;
    self.videoWriter = nil;
    self.previousStamp = 0;
    self.outputBufferPoolAuxAttributes = nil;
    CGColorSpaceRelease(_rgbColorSpace);
    CVPixelBufferPoolRelease(_outputBufferPool);
    
    _isRecording = NO;
    _isPauseRecording = NO;
    
    //1.帧方式
    self.frameCount = 0;
    self.duration = 0; //这个可以不设置，用于观察时间
    
    //2.时间戳方式
    self.previousStamp = 0;
    self.validStamp = 0;
}

#pragma mark - Getters and Setters
- (AVAssetWriter *)videoWriter {
    
    if (_videoWriter == nil) {
        NSError *error = nil;
        _videoWriter = [[AVAssetWriter alloc] initWithURL:self.videoURL fileType:AVFileTypeQuickTimeMovie error:&error];
    }
    return _videoWriter;
}

- (NSString *)videoPath {
    if (_videoPath == nil) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _videoPath = [docPath stringByAppendingPathComponent:@"screenCapture.mp4"];
        NSLog(@"%@", _videoPath);
    }
    return _videoPath;
}

- (NSURL *)videoURL {
    return [NSURL fileURLWithPath:self.videoPath];
}

@end
