//
//  TestController.m
//  TreasureChest
//
//  Created by jf on 2020/11/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestController.h"
#import "XMNetworking.h"
#import "Test2Controller.h"
#import "DownloadViewController.h"

@interface TestController ()

@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;
@property(nonatomic, strong)UISlider *slider;
@property(nonatomic, strong)UIImageView *imgView;

@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
}

#pragma mark - < event >

- (void)buttonEvent:(UIButton *)button {
    Test2Controller *controller = [[Test2Controller alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)button2Event:(UIButton *)button {
    DownloadViewController *controller = [[DownloadViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)button3Event:(UIButton *)button {

}

- (void)sliderValueChange:(UISlider *)slider {
    NSLog(@"slider.value = %f",slider.value);

}

#pragma mark - < test >

#pragma mark - < init view >
- (void)setupSubviews {
    self.imgView = [[UIImageView alloc]init];
    self.imgView.userInteractionEnabled = false;
    [self.view addSubview:_imgView];
    _imgView.frame = CGRectMake(10, 90, 150, 150/(640/480.0));
    _imgView.layer.borderWidth = 1;
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.layer.borderWidth = 1;
    _button.backgroundColor = [UIColor whiteColor];
    [_button setTitle:@"跳转页面1" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.layer.borderWidth = 1;
    button2.backgroundColor = [UIColor whiteColor];
    [button2 setTitle:@"跳转页面2" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2Event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.layer.borderWidth = 1;
    button3.backgroundColor = [UIColor whiteColor];
    [button3 setTitle:@"切换按钮2" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(button3Event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    _button.frame = CGRectMake(300, 70, 90, 44);
    button2.frame = CGRectMake(300, 170, 90, 44);
    button3.frame = CGRectMake(300, 270, 90, 44);
    
    self.slider.frame = CGRectMake(30, KScreenHeight - 160, KScreenWidth - 60, 30);
}

- (UISlider *)slider {
    if (_slider == nil) {
        _slider = [[UISlider alloc]init];
        _slider.maximumValue = 1;
        _slider.minimumValue = 0;
        [_slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_slider];
    }
    return _slider;
}

@end
