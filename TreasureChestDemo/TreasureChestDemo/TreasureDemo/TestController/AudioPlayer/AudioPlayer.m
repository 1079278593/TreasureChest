//
//  AudioPlayer.m
//  Poppy_Dev01
//
//  Created by jf on 2020/9/22.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "AudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

static AudioPlayer *manager = nil;

@interface AudioPlayer () <AVAudioPlayerDelegate>

@property(nonatomic, strong)NSMutableArray <AVPlayer *> *players;

@end

@implementation AudioPlayer

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AudioPlayer alloc]init];
    });
    return manager;
}

- (instancetype)init {
    if(self == [super init]){
        [self bindRACModel];
    }
    return self;
}

- (void)bindRACModel {
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil] subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"声音设置 播放完成");
        @synchronized (self) {
            [self.players.lastObject pause];
            NSError *error;
            [[AVAudioSession sharedInstance] setActive:NO error:&error];
        }
        
        [[GameLiveCenter shareInstance] effectAudioStart:NO];
    }];
}

#pragma mark - < public >
- (void)playSound:(NSString *)fileName fileType:(NSString *)fileType {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    if (path.length > 0) {
        [self playSound:path];
    }
}

- (void)stopSound {
    for (AVPlayer *player in self.players) {
        [player pause];
    }
}

#pragma mark - < player >
- (void)playSound:(NSString *)filePath {
    
//    [self systemSoundId:filePath];
//    return;
    
    [[GameLiveCenter shareInstance] effectAudioStart:YES];
    [self getSystemVolumSlider].value = 1;
    [self deviceSetActive];
    
    NSURL *url  = [NSURL fileURLWithPath:filePath];
    AVPlayerItem *songItem = [[AVPlayerItem alloc]initWithURL:url];
    AVPlayer *player = [[AVPlayer alloc]initWithPlayerItem:songItem];
    [player play];
    player.volume = 1.0;
    [self.players addObject:player];
    
    if (self.players.count > 5) {
        [self.players[0] pause];
        [self.players removeObjectAtIndex:0];//简单的方式；实际需要增加delegate判断播放完了就删除
    }
}

#pragma mark - < priavte >
- (void)deviceSetActive {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
//    [audioSession setActive:NO error:&error]; //让我的App占用听筒或扬声器
    if (error) {
        NSLog(@"声音设置1：%@",error);
    }

    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setMode:AVAudioSessionModeVoiceChat error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];//设置为公放模式(可以考虑听筒)
    if (self.players.count == 0) {
        [audioSession setActive:YES error:&error]; //让我的App占用听筒或扬声器
    }
    
    if (error) {
        NSLog(@"声音设置2：%@",error);
    }
}

- (NSMutableArray<AVPlayer *> *)players {
    if (_players == nil) {
        _players = [NSMutableArray arrayWithCapacity:0];
    }
    return _players;
}


/*
 *获取系统音量滑块
 */
- (UISlider *)getSystemVolumSlider{
    static UISlider * volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 4)];
        
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    
    // retrieve system volumefloat systemVolume = volumeViewSlider.value;
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:1.0f animated:NO];
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    return volumeViewSlider;
}

/**
 //这个path也可以是系统音频文件夹的位置
 //提示音音频文件位置:/System/Library/Audio/UISounds
 //电话音频文件位置:/Library/Ringtones
 //NSString * path = @"/Library/Ringtones/Waves.m4r"
 
 1. 系统声音服务提供了一个　Api，用于播放不超过　30　秒的声音。它支持的文件格式有限，
 具体的说只有　CAF、AIF　和使用　PCM　或　IMA/ADPCM　数据的　WAV　文件

 2，系统声音服务支持如下三种类型：
 （1）声音：立刻播放一个简单的声音文件。如果手机静音，则用户什么也听不见。
 （2）提醒：播放一个声音文件，如果手机设为静音或震动，则通过震动提醒用户。
 （3）震动：震动手机，而不考虑其他设置。

 */
- (void)audioPlayerWithFilePath:(NSString *)filePath {
    NSURL *url  = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    [player play];
}

- (void)systemSoundId:(NSString *)filePath {
    //播放test.wav文件
    //当soundIDTest == kSystemSoundID_Vibrate的时候为震动
    int index = arc4random() % 5;
    SystemSoundID soundIDTest = index;
//    static SystemSoundID soundIDTest1 = kSystemSoundID_Vibrate;
    NSLog(@"系统播放方式：%@",filePath);
    if (filePath) {
         AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:filePath], &soundIDTest );
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:nil];

    
    AudioServicesPlaySystemSound( soundIDTest );
}
/*
 * 错误码对比，可以发现上面[audioSession setActive:NO error:&error];的错误码为：AVAudioSessionErrorCodeIsBusy
 AVAudioSessionErrorCodeNone                         =  0,
 AVAudioSessionErrorCodeMediaServicesFailed          = 'msrv',           0x6D737276, 1836282486
 AVAudioSessionErrorCodeIsBusy                       = '!act',           0x21616374, 560030580
 AVAudioSessionErrorCodeIncompatibleCategory         = '!cat',           0x21636174, 560161140
 AVAudioSessionErrorCodeCannotInterruptOthers        = '!int',           0x21696E74, 560557684
 AVAudioSessionErrorCodeMissingEntitlement           = 'ent?',           0x656E743F, 1701737535
 AVAudioSessionErrorCodeSiriIsRecording              = 'siri',           0x73697269, 1936290409
 AVAudioSessionErrorCodeCannotStartPlaying           = '!pla',           0x21706C61, 561015905
 AVAudioSessionErrorCodeCannotStartRecording         = '!rec',           0x21726563, 561145187
 AVAudioSessionErrorCodeBadParam                     = -50,
 AVAudioSessionErrorInsufficientPriority             = '!pri',           0x21707269, 561017449
 AVAudioSessionErrorCodeResourceNotAvailable         = '!res',           0x21726573, 561145203
 AVAudioSessionErrorCodeUnspecified                  = 'what'            0x77686174, 2003329396
*/



@end
