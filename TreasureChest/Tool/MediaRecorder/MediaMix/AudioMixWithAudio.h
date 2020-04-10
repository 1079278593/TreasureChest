//
//  AudioMixWithAudio.h
//  helloLaihua
//
//  Created by 小明 on 2017/8/31.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "AudioRecorderModel.h"

typedef void (^MergeCompletion)(NSString *outputPath);

@interface AudioMixWithAudio : NSObject

+ (void)addAudioVolumeWithAudioPath:(NSString *)audioPath withCompletion:(MergeCompletion)completion;
+ (NSArray *)videoMixAudioWithComposition:(AVMutableComposition **)composition audios:(NSArray<AudioRecorderModel *> *)audios videoDuration:(CMTime)duration;
@end
