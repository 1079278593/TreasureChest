//
//  MediaMixtureManager.m
//  helloLaihua
//
//  Created by 小明 on 2017/9/11.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import "MediaMixtureManager.h"
#import "AudioMixWithVideo.h"

@interface MediaMixtureManager ()

@property (nonatomic ,strong) ScreenRecorder *screenRecorder;
@property (nonatomic ,strong) AudioMixWithVideo *videoMix;

@end

@implementation MediaMixtureManager

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
        [self initConfig];
    }
    return self;
}

- (void)initConfig {
    
    self.screenRecorder = [ScreenRecorder sharedInstance];
    self.videoMix = [AudioMixWithVideo sharedInstance];
//    [self addNotification];
}

#pragma mark - Events

#pragma mark system events
- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[ScreenRecorder sharedInstance]forceStopRecording];
//    [self pauseRecord];
//    double delayInSeconds = 2.0;
//    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void) {
//        [self resumeRecord];
//    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [self pauseRecord];
//    double delayInSeconds = 2.0;
//    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void) {
//        [self resumeRecord];
//    });
}

#pragma mark - video recorder
- (void)startRecord:(RecordFinishBlock)finishBlock {
    
    NSAssert(self.recorderView != nil, @"必须传入‘想要录制视频的view’");
    [self removeSourceWithPath:OutputSourcePath];
    
    __block MediaMixtureManager *weakSelf = self;
    self.screenRecorder.recorderView = self.recorderView;
    self.screenRecorder.expireDirection = UIDeviceOrientationPortrait;
    [self.screenRecorder startRecording];
    
    self.screenRecorder.frameCountBlock = ^(NSInteger frameCount) {
//        weakSelf.progress = ((CGFloat)frameCount/frameRate)/[WorkManager sharedWorkManager].exportingWork.totalTime.floatValue;
    };
    
    self.screenRecorder.finishBlock = ^(NSString *path) {
//        pathBlock(path);
        
        //开始合成录音
        [weakSelf startAudioMerge:^(NSString *path) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"音频合成.完成:%@",path);
                finishBlock(path);
//                [WorkManager sharedWorkManager].exportingWork = nil;
            });
        }];
    };
}

- (void)stopRecord {
    //
#warning 这个方法还有问题
    __block MediaMixtureManager *weakSelf = self;
    
    [self.screenRecorder stopRecording];
    self.screenRecorder.finishBlock = ^(NSString *path) {
        //开始合成录音
        [weakSelf startAudioMerge:^(NSString *path) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"音频合成.完成:%@",path);
//                pathBlock(path);
//                [WorkManager sharedWorkManager].exportingWork = nil;
            });
        }];
    };
    
}

- (void)pauseRecord {
    
    [self.screenRecorder pauseRecording];
}

- (void)resumeRecord {
    
    [self.screenRecorder resumeRecording];
}

#pragma mark - audio merge
- (void)startAudioMerge:(void (^)(NSString * path))mergePath {
    
    NSURL *url = [NSURL fileURLWithPath:self.screenRecorder.videoPath];

    [self.videoMix startMergeWithVideo:url inputAudios:self.inputAudios withCompletion:^(NSString *outputPath) {
    
        if (outputPath) {
            mergePath(outputPath);
            [self saveVideoWithPath:outputPath];
        }else {//合成失败
            mergePath([ScreenRecorder sharedInstance].videoPath);
            [self saveVideoWithPath:[ScreenRecorder sharedInstance].videoPath];
        }
        
        
    }];
}

#pragma mark - Private Methods

- (void)saveVideoWithPath:(NSString *)sourcePath {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:sourcePath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Error copying video to camera roll:%@", [error localizedDescription]);
        } else {
            NSLog(@"Save Success, Path: %@", self.screenRecorder.videoPath);
        }
    }];
}

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)removeSourceWithPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        if (![fm removeItemAtPath:path error:nil]) {
            NSLog(@"remove audio.wav failed.");
        }
    }
}

- (NSString *)becomeLocalPath:(NSString *)path {
    return nil;
}
@end
