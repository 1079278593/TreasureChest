//
//  MediaRecorder.m
//  TreasureChest
//
//  Created by jf 小明 2020/8/15.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "MediaConfig.h"

@interface VideoRecorder ()

@property(nonatomic, strong)AVAssetWriter *videoWriter;
@property(nonatomic, strong)AVAssetWriterInput *videoWriterInput;
@property(nonatomic, strong)AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
@property(nonatomic, strong)NSDictionary *outputBufferPoolAuxAttributes;

@property(nonatomic, retain)dispatch_queue_t render_queue;
@property(nonatomic, retain)dispatch_queue_t append_pixelBuffer_queue;
@property(nonatomic, retain)dispatch_semaphore_t frameRenderingSemaphore;
@property(nonatomic, retain)dispatch_semaphore_t pixelAppendSemaphore;

@property(nonatomic, assign)CGColorSpaceRef rgbColorSpace;
@property(nonatomic, assign)CVPixelBufferPoolRef outputBufferPool;

@property(nonatomic, strong)CADisplayLink *displayLink;

@property(nonatomic, strong)NSString *videoPath;
@property(nonatomic, strong)NSURL *videoURL;      //videoPath的URL形式
@property(nonatomic, assign)BOOL isRecording;

@property(nonatomic, weak)UIView *recorderView;     //因为是单例，所以强引用会导致无法释放
@property(nonatomic, assign)CGFloat totalTime;      //录制总时间
@property(nonatomic, assign)CGSize resolution;      //分辨率，一般是recorderView的size
@property(nonatomic, assign)CGFloat scale;          //分辨率倍数

/*
 * CMTime的scale，默认给1000。
 CMTime定义是一个C语言的结构体，CMTime是以分数的形式表示时间，value表示分子，timescale表示分母。
 但是由于浮点型数据计算很容易导致精度的丢失，在一些要求高精度的应用场景显然不适合，于是苹果在Core Media框架中定义了CMTime数据类型作为时间的格式
 */
@property(nonatomic, assign)int timeScale;
@property (nonatomic) CFTimeInterval previousStamp;
@property (nonatomic) CFTimeInterval validStamp;

@end

@implementation VideoRecorder

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
        _append_pixelBuffer_queue = dispatch_queue_create("VideoRecorder_appendQueue", DISPATCH_QUEUE_SERIAL);
        _render_queue = dispatch_queue_create("VideoRecorder_renderQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_render_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        _pixelAppendSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Video Record Events
- (void)startWithRecorderView:(UIView *)recorderView {
    [self startWithRecorderView:recorderView videoDuration:CGFLOAT_MAX];
}

- (void)startWithRecorderView:(UIView *)recorderView videoDuration:(CGFloat)duration {
    self.recorderView = recorderView;
    self.totalTime = duration;
    _resolution = recorderView.frame.size;//设置视频尺寸
    
    _timeScale = 1000;
    _scale = [UIScreen mainScreen].scale;
    _scale = 1; //先设置成1
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && _scale > 1) {
        _scale = 1.0;// record half size resolution for retina iPads
    }
    
    NSAssert(_isRecording == NO, @"Is exist an recorder now，please wait until this recorder finish");
    NSAssert((_recorderView != nil || _resolution.width > 0 || _resolution.height > 0), @"Your should provide an correct view");
    
    [self removeVideoFromPath:self.videoPath];
    [self recorderAttributeSetting];
    [self startRecording];
}

- (void)startRecording {
    _isRecording = (self.videoWriter.status == AVAssetWriterStatusWriting);
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(recordRunloop)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.preferredFramesPerSecond = frameRate;
}

- (void)stopRecording {
    if (!_isRecording) return;//或者给个‘提示’
    [self recordFinish];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)recordFinish;
{
    NSLog(@"recordFinishWithSession");
    dispatch_async(_render_queue, ^{
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

#pragma mark - recording
- (void)recordRunloop {
    
    if (!self.isRecording) {
        NSLog(@"视频已经结束录制");
        return;
    }
    
    if (dispatch_semaphore_wait(_frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    
    // throttle the number of frames to prevent meltdown
    // technique gleaned from Brad Larson's answer here: http://stackoverflow.com/a/5956119
    dispatch_async(_render_queue, ^{
        if (![self.videoWriterInput isReadyForMoreMediaData]) return;
        
        CMTime time;
        //按照时间:(第几秒,时间尺度：首选的时间尺度"每秒的帧数")！
        if (self.previousStamp == 0) {
            self.previousStamp = self.displayLink.timestamp;
        } else {
            self.validStamp += self.displayLink.timestamp - self.previousStamp;
            self.previousStamp = self.displayLink.timestamp;
        }
        time = CMTimeMakeWithSeconds(self.validStamp, self.timeScale);
        NSLog(@"validStamp:%f", self.validStamp);
        NSLog(@"displayLink timestamp:%f", self.displayLink.timestamp);
        
        //-----------
        CVPixelBufferRef pixelBuffer = NULL;
        CGContextRef bitmapContext = [self bitmapContextFromBuffer:&pixelBuffer];
        // draw each window into the context (other windows include UIKeyboard, UIAlert)
        // FIX: UIKeyboard is currently only rendered correctly in portrait orientation
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIGraphicsPushContext(bitmapContext);
            {
                CGContextSetFillColorWithColor(bitmapContext, [UIColor whiteColor].CGColor);
                CGContextFillRect(bitmapContext, CGRectMake(0, 0, self.resolution.width, self.resolution.height));
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
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, _resolution.height);
    
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
                                       (id) kCVPixelBufferWidthKey : @(_resolution.width * _scale),
                                       (id) kCVPixelBufferHeightKey : @(_resolution.height * _scale),
                                       (id) kCVPixelBufferBytesPerRowAlignmentKey : @(_resolution.width * _scale * 4)
                                       };
    
    _outputBufferPool = NULL;
    CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(bufferAttributes), &_outputBufferPool);
    
    NSParameterAssert(self.videoWriter);
    
    NSInteger pixelNumber = _resolution.width * _resolution.height * _scale;
    NSDictionary *videoCompression = @{ AVVideoAverageBitRateKey : @(pixelNumber * 11.4) }; //11.4视频平均压缩率，值10.1相当于AVCaptureSessionPresetHigh，数值越大，显示越精细，当前7.5
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : [NSNumber numberWithInt:_resolution.width * _scale],
                                    AVVideoHeightKey : [NSNumber numberWithInt:_resolution.height * _scale],
                                    AVVideoCompressionPropertiesKey : videoCompression};
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSParameterAssert(_videoWriterInput);
    
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    _videoWriterInput.transform = [self transformFromOrientation];
    
    _avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:nil];
    
    [self.videoWriter addInput:_videoWriterInput];
    
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:CMTimeMake(0, _timeScale)];
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
    if (self.isDeviceOrientation) {
        videoTransform = CGAffineTransformIdentity;
    }
    return videoTransform;
}

///根据path删除上次录制的视频文件
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
