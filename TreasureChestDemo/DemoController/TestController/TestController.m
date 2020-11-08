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

@interface TestController ()

@property(nonatomic, strong)UIButton *button;

@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;


@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setTitle:@"切换按钮" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.frame = CGRectMake(220, 120, 90, 44);
    
    [self initView];
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    
    
    button.selected = !button.selected;
    
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
    
    _frontImgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _frontImgView.image = [UIImage imageNamed:@"bgPic1"];
    [self.view addSubview:_frontImgView];
    [_frontImgView hollowOutWithRect:CGRectMake(100, 230, 100, 40)];
}

@end
