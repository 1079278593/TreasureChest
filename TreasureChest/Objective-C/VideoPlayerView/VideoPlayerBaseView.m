//
//  VideoPlayerBaseView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoPlayerBaseView.h"

@interface VideoPlayerBaseView()

@property(nonatomic, strong)NSString *mediaPath;

@end

@implementation VideoPlayerBaseView

- (instancetype)init {
    if(self == [super init]){
        self.player = [[AVPlayer alloc]init];
    }
    return self;
}

//通过这个方式让AVPlayerLayer支持自动布局。
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)dealloc {
    [self removeObservers];
    [self.player removeTimeObserver:self];
}

#pragma mark - < public >
- (void)setupPlayer:(NSString *)mediaPath {
    self.mediaPath = mediaPath;
    [self removeObservers];
    self.playerItme = [self setupPlayerItemWithPath:mediaPath];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItme];
    [(AVPlayerLayer *)self.layer setPlayer:self.player];
    [self addObservers];
}

- (CGFloat)videoDuration {
    return [self mediaDurationWithPlayerItem:self.playerItme];
}

#pragma mark < paly or pause >
- (void)startPlayAtSecond:(CGFloat)second {
    
    [self playerSeekAtSecond:second];
    [self startPlay];
}

- (void)startPlay {
    [self.player play];
}

- (void)pausePlay {
    [self.player pause];
}

- (void)stopPlay {
    [self.player pause];
    [self playerSeekAtSecond:0];
}

- (void)playerSeekAtSecond:(CGFloat)second {
    CMTime time = [self secondToCMTime:second];
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - < observer >
- (void)removeObservers {
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"AVPlayerItemPlaybackStalledNotification" object:nil];
    
}

- (void)addObservers {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerFinished:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInterrupt:) name:@"AVPlayerItemPlaybackStalledNotification" object:nil];
    
    @weakify(self);
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        @strongify(self);
        CGFloat currentSecond = CMTimeGetSeconds(time);
        CGFloat duration = [self videoDuration];
        if (self.progressBlock) {
            self.progressBlock(currentSecond/duration);
        }
    }];
}

- (void)playerFinished:(NSNotification *)notification {
    if (self.finishBlock) {
        self.finishBlock();
    }
}

- (void)playerInterrupt:(NSNotification *)notification {
    
}

#pragma mark - < time >
- (CMTime)secondToCMTime:(CGFloat)second {
    return CMTimeMakeWithSeconds(second, self.playerItme.duration.timescale);
}

- (CGFloat)mediaDurationWithPlayerItem:(AVPlayerItem *)playerItem {
    return CMTimeGetSeconds(playerItem.duration);
}

- (CGFloat)currentTimeWithPlayerItem:(AVPlayerItem *)playerItem {
    return CMTimeGetSeconds(playerItem.currentTime);
}

#pragma mark - < getter and setter >
- (void)setVolume:(CGFloat)volume {
    _volume = volume;
    self.player.volume = volume;
}

- (AVPlayerItem *)setupPlayerItemWithPath:(NSString *)path {
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    if ([path containsString:@"http"]) {
        url = [[NSURL alloc]initWithString:path];
    }
    return [[AVPlayerItem alloc]initWithURL:url];
}
 
@end
