//
//  AudioMixWithVideo.h
//  helloLaihua
//
//  Created by 小明 on 2017/8/31.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioMixWithAudio.h"
#import "AudioRecorderModel.h"

#define OutputSourcePath [NSTemporaryDirectory() stringByAppendingPathComponent:@"screenRecord.mp4"]

typedef void (^MergeCompletion)(NSString *outputPath);

@interface AudioMixWithVideo : NSObject

+ (instancetype)sharedInstance;

/*!
 @method         startMergeWithVideo:inputAudios:withCompletion:
 @abstract       Merge the video and audios.
 @param          videoURL
                 The videoURL is the local path of video.
 @param          audios
                 Provide the audios for mix with the video.
 @param          completion
                 A block called when merge finish, and output a video path.
 */
- (void)startMergeWithVideo:(NSURL *)videoURL inputAudios:(NSArray<AudioRecorderModel *> *)audios withCompletion:(MergeCompletion)completion;

@end
