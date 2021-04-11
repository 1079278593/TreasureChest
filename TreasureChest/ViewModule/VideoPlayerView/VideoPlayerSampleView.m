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
        [self setupSubviews];
        [self blockMethod];
    }
    return self;
}

- (void)setupSubviews {
    self.playerView = [[VideoPlayerBaseView alloc]init];
    [self addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"ic_advertise_videoBtn"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.hidden = true;
    [self addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(@50);
    }];
    
    self.slider = [[UISlider alloc]init];
    self.slider.tintColor = [UIColor redColor];
    [self.slider addTarget:self action:@selector(sliderEvent:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderTouchUP:) forControlEvents:UIControlEventTouchUpInside];
    self.slider.enabled = false;
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.bottom.equalTo(self).offset(-10);
        make.height.equalTo(@40);
    }];
}

#pragma mark - < public method >
- (void)setupPlayer:(NSString *)mediaPath {
    [self.playerView setupPlayer:mediaPath];
}

#pragma mark - < button event >
- (void)playBtnEvent:(UIButton *)button {
//    if (button.selected) {
//        [self.playerView pausePlay];
//    }else {
        [self.playerView startPlay];
//    }
//    button.selected = !button.selected;
    button.hidden = true;
}

- (void)sliderEvent:(UISlider *)slider {
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
    
    self.playerView.preparedBlock = ^{
        @strongify(self)
        self.playButton.hidden = false;
        self.slider.enabled = true;
    };
    
    self.playerView.finishBlock = ^{
        @strongify(self)
        self.playButton.hidden = false;
    };
}
@end
