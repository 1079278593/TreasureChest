//
//  VideoPlayerSampleView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoPlayerSampleView.h"

@interface VideoPlayerSampleView()

@property(nonatomic, strong)VideoPlayerBaseView *playerView;
@property(nonatomic, strong)UIButton *playButton;
@property(nonatomic, strong)UISlider *slider;

@end

@implementation VideoPlayerSampleView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
    }
    return self;
}

- (void)initView {
    self.playerView = [[VideoPlayerBaseView alloc]init];
    [self addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton addTarget:self action:@selector(playBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(@50);
    }];
    self.playButton.layer.borderWidth = 1;
}

- (void)playBtnEvent:(UIButton *)button {
    NSString *path = @"/Users/xiaoming/Downloads/haizeiwang.mp4";
    [self.playerView setupPlayer:path];
    
    double delayInSeconds = 1.2;
    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
        [self.playerView startPlayAtTime:230];
    });
}

@end
