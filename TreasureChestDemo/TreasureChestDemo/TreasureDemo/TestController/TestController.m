//
//  TestController.m
//  TreasureChest
//
//  Created by jf on 2020/11/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestController.h"
#import "RectProgressView.h"
#import "UIView+RoundProgress.h"
#import "UIView+HollowOut.h"
#import "TestView.h"
#import "AudioPlayer.h"
#import "Lottie.h"
#import "LottiePlayerView.h"

@interface TestController ()

@property(nonatomic, strong)UIButton *button;

@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;
@property(nonatomic, strong)LottiePlayerView *lottiePlayerView;


@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.layer.borderWidth = 1;
    [_button setTitle:@"切换按钮" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.frame = CGRectMake(220, 70, 90, 44);
    
    self.lottiePlayerView = [[LottiePlayerView alloc]init];
    [self.view addSubview:self.lottiePlayerView];
    self.lottiePlayerView.frame = CGRectMake(0, 120, KScreenWidth, 400);
    self.lottiePlayerView.layer.borderWidth = 1;
    
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    //https://o.yinliqu.com/gift/xiezi2.json
    //https://o.yinliqu.com/gift/zhizhu2.json
    //https://o.yinliqu.com/gift/dabai.json
//    NSString *url = @"https://o.yinliqu.com/gift/xiezi2.json";
    NSArray *paths = @[@"https://o.yinliqu.com/gift/xiezi2.json",
                       @"https://o.yinliqu.com/gift/zhizhu2.json",
                       @"https://o.yinliqu.com/gift/dabai.json"];
    int index = arc4random() % 3;
    [self.lottiePlayerView showLottieWithUrl:paths[index]];
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
}

@end
