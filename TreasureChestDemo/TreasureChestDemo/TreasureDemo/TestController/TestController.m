//
//  TestController.m
//  TreasureChest
//
//  Created by jf on 2020/11/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestController.h"
#import "RectProgressView.h"
#import "OpenGLPixelBufferView.h"
#import "FaceMaskRenderer.h"
#import "FileManager.h"

@interface TestController ()

@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;

@property(nonatomic, strong)OpenGLPixelBufferView *preview;
@property(nonatomic, strong)FaceMaskRenderer *render;

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
    
    self.preview = [[OpenGLPixelBufferView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.preview];
    self.preview.frame = CGRectMake(0, 200, 200, 200);
    
    self.render = [[FaceMaskRenderer alloc]init];
//    self.render 
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    FileManager *manager = [FileManager shareInstance];
//    [manager resourcePathFromFaceMaskName:@"怪兽" resourceName:@"split.tnnmodel" url:@""];
    NSString *lottieUrl = @"http://o.yinliqu.com/default/741b4c9dea5747a995c6d0cd24dda2bd.json";
    NSString *modelUrl = @"https://o.yinliqu.com/model/android/lime/24.tnnproto";
    NSLog(@"file before block");
    [manager resourcePathWithType:FilePathTypeFaceBox foldName:@"怪兽" fileName:@"1.tnnproto" url:modelUrl complete:^(NSString * _Nonnull path) {
        NSLog(@"file：%@",path);
    }];
    NSLog(@"file after block");
}

- (void)button2Event:(UIButton *)button {
    [[FileManager shareInstance] deleteWithFileName:@"FaceBox" type:FilePathTypeRoot];
}

- (void)button3Event:(UIButton *)button {
    [[FileManager shareInstance] deleteWithFileName:@"怪兽" type:FilePathTypeFaceBox];
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
}



@end
