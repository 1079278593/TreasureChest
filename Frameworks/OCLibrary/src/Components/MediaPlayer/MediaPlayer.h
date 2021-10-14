//
//  MediaPlayer.h
//  Poppy_Dev01
//
//  Created by jf on 2021/3/13.
//  Copyright © 2021 YLQTec. All rights reserved.
//  和系统重名了，待重命名

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaPlayer : NSObject

@property(nonatomic, strong)NSString *bgmUrl;       //!< 背景音的URL
@property(nonatomic, strong)NSString *audioPath;    //!< 录音的本地路径
@property(nonatomic, assign)CGFloat bgmVolume;
@property(nonatomic, assign)CGFloat audioVolume;
@property(nonatomic, assign)BOOL isPlaying;
@property(nonatomic, assign)CGFloat videoDuration;

//第一步，传入url、path
- (void)prepareWithUrl:(NSString *)bgmUrl recordAudio:(NSString *)audioPath;
- (void)replaceBgmWithUrl:(NSString *)bgmUrl;//!< 替换背景音乐

//第二步，播放
- (void)playAtSecond:(CGFloat)second bgmVolume:(CGFloat)bgmVolume audioVolume:(CGFloat)audioVolume;

//第三步，暂停
- (void)stopPlaySound;

//销毁播放器
- (void)destroy;


- (NSString *)getBgmLocalPath;//待删除

@end

NS_ASSUME_NONNULL_END
