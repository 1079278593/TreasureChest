//
//  SoundPlayer.h
//  Poppy_Dev01
//
//  Created by ming on 2021/3/20.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SoundPlayer;

NS_ASSUME_NONNULL_BEGIN

@protocol SoundPlayerDelegate <NSObject>

- (void)soundPlayerPrepareDone:(SoundPlayer *)player;
- (void)soundPlayer:(SoundPlayer *)player progress:(CGFloat)progress;
- (void)soundPlayerFinish:(SoundPlayer *)player;

@end




@interface SoundPlayer : NSObject

@property(nonatomic, weak)id<SoundPlayerDelegate> delegate;
@property(nonatomic, assign)CGFloat videoDuration;
@property(nonatomic, assign)id timeObserver;

//第一步，传入url、path
- (void)prepareWithUrl:(NSString *)urlString;
- (void)prepareWithLocalPath:(NSString *)path;

//第二步，播放
- (void)playAtSecond:(CGFloat)second volume:(CGFloat)volume;
- (CGFloat)currentTime;//当前播放到哪一秒

//第三步，暂停
- (void)pausePlay;
- (void)stopPlay;

//销毁播放器
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
