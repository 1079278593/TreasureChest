//
//  DetectFaceController.m
//  TreasureChest
//
//  Created by jf on 2020/10/9.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "DetectFaceController.h"
#import "DetectImageController.h"
#import "CameraController.h"
#import "OpenGLController.h"

@interface DetectFaceController ()

@property(nonatomic, strong)UIButton *imageButton;
@property(nonatomic, strong)UIButton *cameraButton;
@property(nonatomic, strong)UIButton *openGLButton;

@end

@implementation DetectFaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = false;
}

#pragma mark - < event >
- (void)imageButtonEvent:(UIButton *)button {
    DetectImageController *controller = [[DetectImageController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cameraButtonEvent:(UIButton *)button {
    CameraController *controller = [[CameraController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)openGLButtonEvent:(UIButton *)button {
    OpenGLController *controller = [[OpenGLController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - < init view >
- (void)setupSubviews {
    _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_imageButton setTitle:@"图片检测" forState:UIControlStateNormal];
    [_imageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_imageButton addTarget:self action:@selector(imageButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageButton];
    [_imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(80);
        make.width.equalTo(@100);
        make.height.equalTo(@45);
    }];
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setTitle:@"相机检测" forState:UIControlStateNormal];
    [_cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cameraButton addTarget:self action:@selector(cameraButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraButton];
    [_cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.imageButton.mas_bottom).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(@45);
    }];
    
    _openGLButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openGLButton setTitle:@"openGL" forState:UIControlStateNormal];
    [_openGLButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_openGLButton addTarget:self action:@selector(openGLButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openGLButton];
    [_openGLButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.cameraButton.mas_bottom).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(@45);
    }];
}

@end
