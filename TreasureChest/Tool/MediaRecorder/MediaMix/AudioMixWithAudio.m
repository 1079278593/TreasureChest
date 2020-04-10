//
//  AudioMixWithAudio.m
//  helloLaihua
//
//  Created by 小明 on 2017/8/31.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import "AudioMixWithAudio.h"

@interface AudioMixWithAudio ()

/// 根据模板文件格式，提取所有场景的audio(包括：类型、起始时间、路径)
@property (nonatomic ,strong)NSArray *inputAudios;

@end

@implementation AudioMixWithAudio

#pragma mark - audio mix with audio
+ (void)addAudioVolumeWithAudioPath:(NSString *)audioPath withCompletion:(MergeCompletion)completion {
    NSString *docPath = NSTemporaryDirectory();
    NSString *outputPath = [docPath stringByAppendingPathComponent:@"AudioRecord.m4a"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:outputPath]) {
        if (![fm removeItemAtPath:outputPath error:nil]) {
            NSLog(@"remove old output file failed.");
        }
    }
    

    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:0];
 
        
    NSURL *assetURL = [NSURL fileURLWithPath:audioPath];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    Float64 audioTime = CMTimeGetSeconds(asset.duration);
    Float64 audioStartTime = 0.0;
    
    if (asset == nil || audioTime <= 0 || isnan(audioTime)) {
        return;
    }
    
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];//Can be default ,need try.
    [parameters addObject:inputParameters];
    
    NSError *error = nil;
    
    [inputParameters setVolume:4.0 atTime:kCMTimeZero];
    CMTime startTime = CMTimeMakeWithSeconds(audioStartTime, 1);
    
    timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    [track insertTimeRange:timeRange ofTrack:assetTrack atTime:startTime error:&error];

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = parameters;
    
    //- - - - - - - - - - - - - - -
    // create output ,set quality
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    
    // ouput type
    assetExport.outputFileType = @"com.apple.m4a-audio";
    
    //
    assetExport.audioMix = audioMix;
    
    // output address
    assetExport.outputURL = outputURL;
    
    // export
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        //      分发到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(outputPath);
            }
        });
        
    }];
}


+ (AVMutableAudioMixInputParameters *)audioAppendWithComposition:(AVMutableComposition **)composition audioAsset:(AVURLAsset *)asset timeRange:(CMTimeRange)timeRange {
    
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    AVMutableCompositionTrack *track = [*composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];//Can be default ,need try.
    [inputParameters setVolume:2.0 atTime:kCMTimeZero];
    
    NSError *error = nil;
    [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:timeRange.start error:&error];
    
    return inputParameters;
}

#pragma mark - video mix with audios
+ (NSArray *)videoMixAudioWithComposition:(AVMutableComposition **)composition audios:(NSArray<AudioRecorderModel *> *)audios videoDuration:(CMTime)duration {
    
    AVMutableComposition *_composition = *composition;
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:0];
    
    for (AudioRecorderModel *audio in audios) {
        
        NSURL *assetURL = [NSURL fileURLWithPath:audio.sourcePath];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        Float64 videoTime = CMTimeGetSeconds(duration);
        Float64 audioTime = CMTimeGetSeconds(asset.duration);
        Float64 audioStartTime = [audio.startTime floatValue];
        
        if (asset == nil || audioTime <= 0 || isnan(audioTime)) {
            continue;
        }
    
        AVMutableCompositionTrack *track = [_composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];//Can be default ,need try.
        [parameters addObject:inputParameters];
        
        NSError *error = nil;
        if (audio.type == 0) {
            //背景音，音量要小一点
            [inputParameters setVolume:2.0 atTime:kCMTimeZero];
            NSInteger cycleCounts = videoTime/audioTime;
            NSInteger restTime = (int64_t)videoTime%(int64_t)audioTime;
            for (int i = 0; i<cycleCounts; i++) {
                [track insertTimeRange:timeRange ofTrack:assetTrack atTime:CMTimeMake(audioTime*i, 1) error:&error];
            }
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(restTime, 1)) ofTrack:assetTrack atTime:CMTimeMake(audioTime*cycleCounts, 1) error:&error];
        }else{
            [inputParameters setVolume:4.0 atTime:kCMTimeZero];
            CMTime startTime = CMTimeMakeWithSeconds(audioStartTime, 1);
            
            timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            if ((audioStartTime+audioTime)>videoTime) {
                timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(videoTime - audioStartTime, 1));
            }
            
            [track insertTimeRange:timeRange ofTrack:assetTrack atTime:startTime error:&error];
        }
        
    }
    
    return parameters;
}

@end
