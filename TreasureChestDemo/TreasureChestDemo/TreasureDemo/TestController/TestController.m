//
//  TestController.m
//  TreasureChest
//
//  Created by jf on 2020/11/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestController.h"
#import "Lottie.h"
#import "XMNetworking.h"

#import "RectProgressView.h"
#import "OpenGLPixelBufferView.h"
#import "FaceMaskRenderer.h"
#import "FileManager.h"
#import "TestSubView.h"
#import "EffectResourceDownloador.h"

@interface TestController ()

@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;
@property(nonatomic, strong)UISlider *slider;
@property(nonatomic, strong)UIImageView *imgView;

@property(nonatomic, strong)LOTAnimationView *lottieView;

@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self testView];
    [self testMethod];
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {

}

- (void)button2Event:(UIButton *)button {
    
}

- (void)button3Event:(UIButton *)button {
    
}

- (void)sliderValueChange:(UISlider *)slider {
    NSLog(@"slider.value = %f",slider.value);

}

#pragma mark - < test >
- (void)testView {
    
}

- (void)testMethod {
//    [self request];
}

- (void)request {
    NSString *BaseURL_User = @"http://47.107.135.1:7005/api/v1/user";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"mobileModel"] = @"ios";
    parameters[@"appType"] = @1;    //应用类型[1：android，2：ios]
    
    NSString *url = [BaseURL_User stringByAppendingString:@"/ar/get"];
    [[XMNetworking sharedManager] GET:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        id response = responseObject[@"response"];
        EffectARealityModel *model = [EffectARealityModel mj_objectWithKeyValues:response];
        [self download:model];
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
    }];
}

- (void)download:(EffectARealityModel *)model {
    //1.下载mask的tnn模型:tnnmodel和tnnproto，缩略图(),文件名用name
    
    //2.下载场景
    
    //3.下载lottie
    
    //4.
    
    EffectResourceDownloador *download = [[EffectResourceDownloador alloc]init];
    [download downloadWith:model];
    
}



#pragma mark - < init view >
- (void)setupSubviews {
    _bgImgView = [[UIImageView alloc]init];
    int index = arc4random() % 7 + 1;
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"testDemoBg%d",index] ofType:@"jpeg"];
    _bgImgView.image = [UIImage imageWithContentsOfFile:path];
//    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
    
    self.imgView = [[UIImageView alloc]init];
    self.imgView.userInteractionEnabled = false;
    [self.view addSubview:_imgView];
    _imgView.frame = CGRectMake(10, 90, 150, 150/(640/480.0));
    _imgView.layer.borderWidth = 1;
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.layer.borderWidth = 1;
    _button.backgroundColor = [UIColor whiteColor];
    [_button setTitle:@"切换按钮1" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.frame = CGRectMake(300, 70, 90, 44);
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.layer.borderWidth = 1;
    button2.backgroundColor = [UIColor whiteColor];
    [button2 setTitle:@"切换按钮2" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2Event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    button2.frame = CGRectMake(300, 170, 90, 44);
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.layer.borderWidth = 1;
    button3.backgroundColor = [UIColor whiteColor];
    [button3 setTitle:@"切换按钮2" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(button3Event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    button3.frame = CGRectMake(300, 270, 90, 44);
    
    self.slider.frame = CGRectMake(30, KScreenHeight - 160, KScreenWidth - 60, 30);
}

- (NSArray *)getDatas {
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"lotties" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSArray *lotties = [bundle pathsForResourcesOfType:@"" inDirectory:@""];
    return lotties;
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
