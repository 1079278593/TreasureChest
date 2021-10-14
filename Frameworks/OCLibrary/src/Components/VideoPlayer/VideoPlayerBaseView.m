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
@property(nonatomic, assign)id timeObserver;
@property(nonatomic, assign)CGFloat progressRatio;

@end

@implementation VideoPlayerBaseView

- (instancetype)init {
    if(self == [super init]){
        self.player = [[AVPlayer alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEndNotification) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    }
    return self;
}

//通过这个方式让AVPlayerLayer支持自动布局。
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.activityView.center = self.center;
}

- (void)dealloc {
    [self.player removeTimeObserver:_timeObserver];
    [self.playerItme removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - < public >
- (void)setupPlayer:(NSString *)mediaPath {
    self.mediaPath = mediaPath;
    self.playerItme = [self setupPlayerItemWithPath:mediaPath];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItme];
    [(AVPlayerLayer *)self.layer setPlayer:self.player];
    [self addObservers];
}

- (CGFloat)videoDuration {
    return [self mediaDurationWithPlayerItem:self.playerItme];
}

- (CGFloat)currentDuration {
    return [self currentTimeWithPlayerItem:self.playerItme];
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
    if (time.timescale > 0) {
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (BOOL)isPlaying {
    return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
}

#pragma mark - < observer >
- (void)addObservers {
    __weak __typeof(&*self)weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = CMTimeGetSeconds(time);
        CGFloat duration = [weakSelf videoDuration];
        weakSelf.progressRatio = currentSecond/duration;
        if (weakSelf.progressBlock && !isnan(weakSelf.progressRatio)) {
            weakSelf.progressBlock(weakSelf.progressRatio);
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
                [self.activityView stopAnimating];
                if (self.preparedBlock) {
                    self.preparedBlock();
                }
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
//                [ProgressHUD showError:@"视频格式不支持"];
            }
                break;
            case AVPlayerItemStatusFailed:
            {
//                [ProgressHUD showError:@"视频初始化失败"];
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
    if (self.progressRatio >= 1) {
        [self stopPlay];
        if (self.finishBlock) {
            self.finishBlock();
        }
    }
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
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored"-Wdeprecated-declarations"
    path = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)path,  (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",  NULL,  kCFStringEncodingUTF8));
    #pragma clang diagnostic pop
    
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    if ([path containsString:@"http"]) {
        url = [[NSURL alloc]initWithString:path];
    }
    return [[AVPlayerItem alloc]initWithURL:url];
}

- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_activityView];
        [_activityView setHidesWhenStopped:YES];
    }
    return _activityView;
}

@end
