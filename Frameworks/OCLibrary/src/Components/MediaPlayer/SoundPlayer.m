//
//  SoundPlayer.m
//  Poppy_Dev01
//
//  Created by ming on 2021/3/20.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "SoundPlayer.h"
#import "FileManager.h"
#import <AVFoundation/AVFoundation.h>

@interface SoundPlayer ()

@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)AVPlayerItem *playerItme;


@property(nonatomic, assign)CGFloat progress;

@end

@implementation SoundPlayer

- (instancetype)init {
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEndNotification) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    }
    return self;
}

#pragma mark - < public >
//第一步，传入url、path
- (void)prepareWithUrl:(NSString *)urlString {
    [self.player pause];
    
    NSString *path = [self downloadWithPath:urlString];
    NSURL *url;
    if ([path containsString:@"http"]) {
        url = [NSURL URLWithString:path];
    }else {
        url = [NSURL fileURLWithPath:path];
    }
    self.playerItme = [[AVPlayerItem alloc]initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItme];
    
    [self addObservers];
}

- (void)prepareWithLocalPath:(NSString *)path {
    [self.player pause];
    
    self.playerItme = [[AVPlayerItem alloc]initWithURL:[NSURL fileURLWithPath:path]];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItme];
    [self addObservers];//漏了
}

//第二步，播放
- (void)playAtSecond:(CGFloat)second volume:(CGFloat)volume {
    CGFloat duration = CMTimeGetSeconds(self.playerItme.asset.duration);
    CGFloat time = fmod(second, duration);//取余
    NSLog(@"playAtSecond:%f",time);
    [self playerSeekAtSecond:time];
    self.player.volume = volume;
    [self.player play];
}

//第三步，暂停
- (void)pausePlay {
    [self.player pause];
}

- (void)stopPlay {
    [self.player pause];
    [self playerSeekAtSecond:0];
}

- (CGFloat)currentTime {
    return [self currentTimeWithPlayerItem:self.playerItme];
}

- (CGFloat)audioDuration {
    return [self mediaDurationWithPlayerItem:self.playerItme];
}

//销毁播放器
- (void)destroy {
    [self.player removeTimeObserver:_timeObserver];
//    [self.playerItme removeObserver:self forKeyPath:@"status"];
    
    [self.player pause];
    self.player = nil;
    self.playerItme = nil;
}

#pragma mark - < time >
- (CMTime)secondToCMTime:(CGFloat)second {
    return CMTimeMakeWithSeconds(second, self.playerItme.duration.timescale);
}

- (CGFloat)mediaDurationWithPlayerItem:(AVPlayerItem *)playerItem {
    return CMTimeGetSeconds(playerItem.duration);//音频有问题，这个方法
}

- (CGFloat)currentTimeWithPlayerItem:(AVPlayerItem *)playerItem {
    return CMTimeGetSeconds(playerItem.currentTime);
}

#pragma mark - < observer >
- (void)addObservers {
    if (self.timeObserver != nil) {
        [self.player removeTimeObserver:_timeObserver];
        self.timeObserver = nil;
    }
    __weak __typeof(&*self)weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = CMTimeGetSeconds(time);
        CGFloat duration = [weakSelf videoDuration];
        weakSelf.progress = currentSecond/duration;
        if ([weakSelf.delegate respondsToSelector:@selector(soundPlayer:progress:)]) {
            [weakSelf.delegate soundPlayer:weakSelf progress:weakSelf.progress];
        }
    }];
    
    //其实AVPlayerItem和AVPlayer 都有status 属性的，而且可以使用KVO监听。建议用AVPlayerItem
    [self.playerItme addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  context:nil];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {

    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];   //取出status的新值
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                if ([self.delegate respondsToSelector:@selector(soundPlayerPrepareDone:)]) {
                    [self.delegate soundPlayerPrepareDone:self];
                }
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                //格式不支持
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                //初始化失败
            }
                break;
                
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
    
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
    }
}

- (void)playEndNotification {
    if (self.progress >= 1) {
        [self stopPlay];
        if ([self.delegate respondsToSelector:@selector(soundPlayerFinish:)]) {
            [self.delegate soundPlayerFinish:self];
        }
    }
}

#pragma mark - < private >
- (void)playerSeekAtSecond:(CGFloat)second {
//    CMTime time = [self secondToCMTime:second];
    CMTime time = CMTimeMakeWithSeconds(second, self.player.currentTime.timescale);
    if (time.timescale > 0) {
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (NSString *)downloadWithPath:(NSString *)urlString {
    //如果没有缓存就播放在线音乐。
    NSString *filterFileName = [urlString componentsSeparatedByString:@"/"].lastObject;
    __block NSString *localPath = urlString;
    [[FileManager shareInstance] resourcePathWithType:FilePathTypeMusic foldName:KMusicFoldName fileName:filterFileName url:urlString complete:^(NSString * _Nonnull path) {
        if (path.length > 0) {
            localPath = path;
        }
    }];
    return localPath;
}

- (AVPlayer *)player {
    if (_player == nil) {
        _player = [[AVPlayer alloc]init];
    }
    return _player;
}

@end
