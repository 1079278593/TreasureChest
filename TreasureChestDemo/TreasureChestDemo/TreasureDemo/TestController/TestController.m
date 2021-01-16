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
#import "sys/utsname.h"
#import "ThreadResident.h"
#import "ResidentThread.h"

@interface TestController ()

@property(nonatomic, strong)UIButton *button;

@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;
@property(nonatomic, strong)LottiePlayerView *lottiePlayerView;

@property(nonatomic, assign)int index;
@property(nonatomic, strong)ResidentThread *thread;


@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.layer.borderWidth = 1;
    [_button setTitle:@"切换按钮1" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.frame = CGRectMake(220, 70, 90, 44);
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.layer.borderWidth = 1;
    [button2 setTitle:@"切换按钮2" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2Event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    button2.frame = CGRectMake(220, 170, 90, 44);
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.layer.borderWidth = 1;
    [button3 setTitle:@"切换按钮2" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(button3Event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    button3.frame = CGRectMake(220, 270, 90, 44);
    
    _index = 0;
    self.thread = [[ResidentThread alloc]init];
    [self.thread start];
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    [self.thread debugActionAdd:-2];
}

- (void)button2Event:(UIButton *)button {
    [self.thread debugActionAdd:1];
}

- (void)button3Event:(UIButton *)button {
    [self.thread debugActionAdd:3];
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
}



@end
