//
//  MediaMixtureManager.h
//  helloLaihua
//
//  Created by 小明 on 2017/9/11.
//  Copyright © 2017年 laihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ScreenRecorder.h"
#import "AudioMixWithAudio.h"

@interface MediaMixtureManager : NSObject

/*!
 @property      recorderView
 @abstract      Provides the view for recording video
 @discussion
     Can't provide nil for recorderView.
 */
@property (nonatomic ,strong) UIView *recorderView;

/*!
 @property      inputAudios
 @abstract      Provides the array of audios for mix with video. Array content is class SceneAudio.
 @discussion
     set inputAudios if need mix audio with video. If not set,just record video from view and not voice in video.
 */
@property (nonatomic ,strong)NSArray<AudioRecorderModel *> *inputAudios;

//进度
@property (nonatomic, assign) CGFloat progress;

+ (instancetype)sharedInstance;

- (void)startRecord:(RecordFinishBlock)finishBlock;

//- (void)stopRecord;

- (void)pauseRecord;

- (void)resumeRecord;

@end
