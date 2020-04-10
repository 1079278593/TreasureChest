//
//  AudioMixWithVideo.m
//  helloLaihua
//
//  Created by 小明 on 2017/8/31.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import "AudioMixWithVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface AudioMixWithVideo ()

/// 根据模板文件格式，提取所有场景的audio(包括：类型、起始时间、路径)
@property (nonatomic ,strong)NSArray *inputAudios;
@property (nonatomic ,strong)NSURL *inputVideoURL;
@property (nonatomic ,strong)NSURL *outputVideoURL;

@end

@implementation AudioMixWithVideo

#pragma mark - Life Cycle
+ (instancetype)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - start merge
- (void)startMergeWithVideo:(NSURL *)videoURL inputAudios:(NSArray *)audios withCompletion:(MergeCompletion)completion {
    
    // ouput file path
    NSString *outputPath = OutputSourcePath;
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    // start time
    CMTime startTime = kCMTimeZero;
    
    // create composition
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    /// video collect
    // get video asset
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    
    // get video time range
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // create video channel
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // video collect channel
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    // add video collect channel data to a mutable channel
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];

    // audio mix
    NSArray *parameters = [AudioMixWithAudio videoMixAudioWithComposition:&composition audios:audios videoDuration:videoAsset.duration];
    if (parameters.count == 0) {
        //没有音频，直接退出？
        if (completion) {
            completion(nil);
        }
        return;
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = parameters;
    
    //- - - - - - - - - - - - - - -
    // create output ,set quality
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    // ouput type
    assetExport.outputFileType = AVFileTypeMPEG4;
    
    //    
    assetExport.audioMix = audioMix;
    
    // output address
    assetExport.outputURL = outputURL;
    
    // optimization
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    // export
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // delete original video and audio file
    #warning 当前的录制是保存到相册后，删除沙盒资源，根据需求需要更改
        if (completion) {
            completion(outputPath);
        }
    }];
}

@end
