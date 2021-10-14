//
//  MediaPlayer.m
//  Poppy_Dev01
//
//  Created by jf on 2021/3/13.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "MediaPlayer.h"
#import "FileManager.h"
#import "SoundPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MediaPlayer () <SoundPlayerDelegate>

@property(nonatomic, strong)SoundPlayer *bgmPlayer;
@property(nonatomic, strong)SoundPlayer *audioPlayer;

@end

@implementation MediaPlayer

- (instancetype)init {
    if(self = [super init]){
        [self deviceSetActive];
    }
    return self;
}

- (void)dealloc
{
    [self.bgmPlayer destroy];
    self.bgmPlayer = nil;
    [self.audioPlayer destroy];
    self.audioPlayer = nil;
}

#pragma mark - < public >
//第一步，传入url、path
- (void)prepareWithUrl:(NSString *)bgmUrl recordAudio:(NSString *)audioPath {
    self.bgmUrl = bgmUrl;
    self.audioPath = audioPath;
    [self.audioPlayer pausePlay];
    [self.bgmPlayer pausePlay];
    self.audioPlayer = nil;
    self.bgmPlayer = nil;
    
    if (self.bgmUrl.length > 0) {
        [self.bgmPlayer prepareWithUrl:self.bgmUrl];
    }
    if (self.audioPath.length > 0) {
        [self.audioPlayer prepareWithLocalPath:self.audioPath];
    }
}

- (void)replaceBgmWithUrl:(NSString *)bgmUrl {
    self.bgmUrl = bgmUrl;
    if (self.bgmUrl.length > 0) {
        [self.bgmPlayer prepareWithUrl:self.bgmUrl];
    }
}

//第二步，播放
- (void)playAtSecond:(CGFloat)second bgmVolume:(CGFloat)bgmVolume audioVolume:(CGFloat)audioVolume {
    self.bgmVolume = bgmVolume;
    self.audioVolume = audioVolume;
    self.bgmPlayer.videoDuration = self.videoDuration;//播放前赋值‘视频’的时长
    self.audioPlayer.videoDuration = self.videoDuration;//播放前赋值‘视频’的时长。
    [self.bgmPlayer playAtSecond:second volume:bgmVolume];
    [self.audioPlayer playAtSecond:second volume:audioVolume];
    self.isPlaying = YES;
}

//第三步，暂停
- (void)stopPlaySound {
    [self.bgmPlayer stopPlay];
    [self.audioPlayer stopPlay];
    self.isPlaying = NO;
}

//销毁播放器
- (void)destroy {
    [self.bgmPlayer destroy];
    [self.audioPlayer destroy];
    self.bgmPlayer = nil;
    self.audioPlayer = nil;
}

#pragma mark - < delegate >
- (void)soundPlayerPrepareDone:(SoundPlayer *)player {
    
}

- (void)soundPlayer:(SoundPlayer *)player progress:(CGFloat)progress {
    self.isPlaying = YES;
}

- (void)soundPlayerFinish:(SoundPlayer *)player {
    if ([player isEqual:self.bgmPlayer]) {//背景音乐可能时长不够，需要循环。
        [self.bgmPlayer playAtSecond:0 volume:self.bgmVolume];
        NSLog(@"bgmPlayer cycle");
    }
    if ([player isEqual:self.audioPlayer]) {
        [self.audioPlayer playAtSecond:0 volume:self.audioVolume];
        NSLog(@"audioPlayer cycel");
    }
    NSLog(@"soundPlayerFinish, bgmObserver:%@, audioObserver:%@ ",self.bgmPlayer.timeObserver,self.audioPlayer.timeObserver);
    self.isPlaying = NO;
}

#pragma mark - < priavte >
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

- (NSString *)getBgmLocalPath {
    //如果没有缓存就播放在线音乐。
    NSString *fileName = [self.bgmUrl componentsSeparatedByString:@"/"].lastObject;
    __block NSString *localPath;
    [[FileManager shareInstance] synResourcePathWithType:FilePathTypeMusic foldName:KMusicFoldName fileName:fileName url:self.bgmUrl complete:^(NSString * _Nonnull path) {
        localPath = path;
    }];
    return localPath;
}

- (void)deviceSetActive {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];//设置为公放模式(可以考虑听筒)
    [audioSession setActive:YES error:nil]; //让我的App占用听筒或扬声器
}

- (SoundPlayer *)bgmPlayer {
    if (_bgmPlayer == nil) {
        _bgmPlayer = [[SoundPlayer alloc]init];
        _bgmPlayer.delegate = self;
    }
    return _bgmPlayer;
}

- (SoundPlayer *)audioPlayer {
    if (_audioPlayer == nil) {
        _audioPlayer = [[SoundPlayer alloc]init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

@end
