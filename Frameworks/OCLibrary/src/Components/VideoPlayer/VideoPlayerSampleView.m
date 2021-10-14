//
//  VideoPlayerSampleView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoPlayerSampleView.h"

@interface VideoPlayerSampleView()

@property(nonatomic, strong)UIButton *playButton;
@property(nonatomic, strong)UIButton *stopGoOnButton;
@property(nonatomic, strong)UIButton *leftSideButton;
@property(nonatomic, strong)UIButton *rightSideButton;
@property(nonatomic, strong)UISlider *slider;
@property(nonatomic, strong)NSString *mediaPath;

@end

@implementation VideoPlayerSampleView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
        [self blockMethod];
    }
    return self;
}

#pragma mark - < public >
- (void)setupPlayerWithMediaPath:(NSString *)mediaPath {
//    mediaPath = @"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4";
    if (mediaPath == nil || mediaPath.length == 0) {
//        [ProgressHUD showError:@"链接为空"];
        return;
    }
    self.mediaPath = mediaPath;
    [self.playerView setupPlayer:mediaPath];
}

#pragma mark - < button event >
- (void)playBtnEvent:(UIButton *)button {
    [self.playerView startPlay];
    button.hidden = true;
}

- (void)stopGoOnEvent:(UIButton *)button {
    if ([self.playerView isPlaying]) {
        [self.playerView pausePlay];
    }else {
        [self.playerView startPlay];
    }
    button.selected = !button.selected;
}

- (void)tapGesture {
    if (self.playButton.isHidden) {
        self.stopGoOnButton.hidden = !self.stopGoOnButton.hidden;
    }else {
        self.stopGoOnButton.hidden = YES;
    }
}

- (void)sliderEvent:(UISlider *)slider {
    [self.playerView stopPlay];
    CGFloat videoDuration = [self.playerView videoDuration];
    [self.playerView playerSeekAtSecond:(videoDuration*slider.value)];
}

- (void)sliderTouchUP:(UISlider *)slider {
    [self.playerView startPlay];
}

#pragma mark - < block >
- (void)blockMethod {
    __weak __typeof(&*self)weakSelf = self;
    self.playerView.progressBlock = ^(CGFloat progress) {
        weakSelf.slider.value = progress;
    };
    
    self.playerView.preparedBlock = ^{
        weakSelf.slider.hidden = false;
        [weakSelf playBtnEvent:weakSelf.playButton];
        weakSelf.slider.enabled = true;
    };
    
    self.playerView.finishBlock = ^{
        weakSelf.playButton.hidden = false;
        weakSelf.stopGoOnButton.hidden = !weakSelf.playButton.hidden;
    };
}

#pragma mark - < init view >
- (void)initView {
    NSArray *constaraints1, *constaraints2;
    NSLayoutConstraint *constaraints3, *constaraints4;
    
    self.playerView = [[VideoPlayerBaseView alloc]init];
    [self addSubview:self.playerView];
    UIView *view = self.playerView;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    constaraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(view)];
    [self addConstraints:constaraints1];
    [self addConstraints:constaraints2];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"videoBtn"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    view = self.playButton;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    constaraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"[view(50.0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(50.0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints3 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeCenterX];
    constaraints4 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeCenterY];
    [self addConstraints:constaraints1];
    [self addConstraints:constaraints2];
    [self addConstraint:constaraints3];
    [self addConstraint:constaraints4];
    
    //暂停、继续播放
    self.stopGoOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stopGoOnButton setImage:[UIImage imageNamed:@"videoBtn"] forState:UIControlStateNormal];
    [self.stopGoOnButton addTarget:self action:@selector(stopGoOnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopGoOnButton];
    self.stopGoOnButton.hidden = true;
    view = self.stopGoOnButton;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    constaraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"[view(50.0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(50.0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints3 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeCenterX];
    constaraints4 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeCenterY];
    [self addConstraints:constaraints1];
    [self addConstraints:constaraints2];
    [self addConstraint:constaraints3];
    [self addConstraint:constaraints4];
    
    self.slider = [[UISlider alloc]init];
    self.slider.tintColor = [UIColor redColor];
    [self.slider addTarget:self action:@selector(sliderEvent:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderTouchUP:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.slider];
    self.slider.enabled = false;
    self.slider.hidden = true;
    view = self.slider;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    constaraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[view]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(40.0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    constaraints3 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeBottom];
    [self addConstraints:constaraints1];
    [self addConstraints:constaraints2];
    [self addConstraint:constaraints3];
    [self addConstraint:constaraints4];
    
    self.leftSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftSideButton addTarget:self action:@selector(tapGesture) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftSideButton];
    view = self.leftSideButton;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    constaraints3 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeLeft];
    constaraints4 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeTop];
    NSLayoutConstraint *constaraints5 = [self layoutWithView:view attr:NSLayoutAttributeRight equalToView:self.playButton toAttr:NSLayoutAttributeLeft];
    NSLayoutConstraint *constaraints6 = [self layoutWithView:view attr:NSLayoutAttributeBottom equalToView:self.slider toAttr:NSLayoutAttributeTop];
    [self addConstraint:constaraints3];
    [self addConstraint:constaraints4];
    [self addConstraint:constaraints5];
    [self addConstraint:constaraints6];
    
    self.rightSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightSideButton addTarget:self action:@selector(tapGesture) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightSideButton];
    view = self.rightSideButton;
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    constaraints3 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeRight];
    constaraints4 = [self equallyRelatedConstraintWithView:view toView:self attribute:NSLayoutAttributeTop];
    constaraints5 = [self layoutWithView:view attr:NSLayoutAttributeLeft equalToView:self.playButton toAttr:NSLayoutAttributeRight];
    constaraints6 = [self layoutWithView:view attr:NSLayoutAttributeBottom equalToView:self.slider toAttr:NSLayoutAttributeTop];
    [self addConstraint:constaraints3];
    [self addConstraint:constaraints4];
    [self addConstraint:constaraints5];
    [self addConstraint:constaraints6];
}

///与视图同等相关的约束
- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view toView:(UIView *)toView attribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:toView  //例如：self.view
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

- (NSLayoutConstraint *)layoutWithView:(UIView *)view attr:(NSLayoutAttribute)attr equalToView:(UIView *)toView toAttr:(NSLayoutAttribute)toAttr {
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attr
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:toView  //例如：self.view
                                        attribute:toAttr
                                       multiplier:1.0
                                         constant:0.0];
}

@end
