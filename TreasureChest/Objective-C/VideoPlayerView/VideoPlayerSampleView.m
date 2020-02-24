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
        [self blockMethod];
    }
    return self;
}

- (void)initView {
    self.playerView = [[VideoPlayerBaseView alloc]init];
    [self addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    NSString *path = @"/Users/xiaoming/Downloads/haizeiwang.mp4";
    [self.playerView setupPlayer:path];
    
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton addTarget:self action:@selector(playBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.width.height.equalTo(@50);
    }];
    self.playButton.layer.borderWidth = 1;
    
    self.slider = [[UISlider alloc]init];
    self.slider.tintColor = [UIColor redColor];
    [self.slider addTarget:self action:@selector(sliderEvent:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderTouchUP:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right);
        make.right.equalTo(self).offset(-30);
        make.bottom.equalTo(self);
        make.height.equalTo(@30);
    }];
}

- (void)playBtnEvent:(UIButton *)button {
    
    if (button.selected) {
        [self.playerView pausePlay];
    }else {
        [self.playerView startPlay];
    }
    button.selected = !button.selected;
}

- (void)sliderEvent:(UISlider *)slider {
    NSLog(@"%f",slider.value);
    [self.playerView stopPlay];
    CGFloat videoDuration = [self.playerView videoDuration];
    [self.playerView playerSeekAtSecond:(videoDuration*slider.value)];
}

- (void)sliderTouchUP:(UISlider *)slider {
    [self.playerView startPlay];
}

#pragma mark - <  >
- (void)blockMethod {
    @weakify(self)
    self.playerView.progressBlock = ^(CGFloat progress) {
        @strongify(self)
        self.slider.value = progress;
    };
}
@end
