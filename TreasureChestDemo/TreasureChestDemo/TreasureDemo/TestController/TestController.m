//
//  TestController.m
//  TreasureChest
//
//  Created by jf on 2020/11/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestController.h"
#import "Lottie.h"

#import "RectProgressView.h"
#import "OpenGLPixelBufferView.h"
#import "FaceMaskRenderer.h"
#import "FileManager.h"
#import "LottieLoader.h"
#import "TextureModel.h"
#import "ImageConvertor.h"
#import "LottieLoaderManager.h"
#import "DraggableCardController.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface TestController ()

@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;
@property(nonatomic, strong)UISlider *slider;
@property(nonatomic, strong)UIImageView *imgView;

@property(nonatomic, strong)LOTAnimationView *lottieView;
@property(nonatomic, strong)LottieLoader *lottieLoader;
@property(nonatomic, strong)NSMutableArray <TextureModel *> *buffers;

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
    
    self.slider.frame = CGRectMake(30, KScreenHeight - 160, KScreenWidth - 60, 30);

}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    /**
     水果： http://o.yinliqu.com/default/741b4c9dea5747a995c6d0cd24dda2bd.json
     蝴蝶： http://o.yinliqu.com/default/e5e9ab385df64b5b8ee63c1e85362ada.json
     烟雾： http://o.yinliqu.com/default/4535e11bcda1477e85b94a87352234b2.json  有问题？
     爱心： http://o.yinliqu.com/default/eb01b10796f84ca9b80838f6da03a501.json
     玫瑰： http://o.yinliqu.com/default/139d31294b294e88a5b3455538359b12.json
     气泡： http://o.yinliqu.com/default/e5146d78b8564b3682540ff07efbc2bc.json
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *lottieUrl = @"http://o.yinliqu.com/default/741b4c9dea5747a995c6d0cd24dda2bd.json";
        [self loadWithUrl:lottieUrl];
    });
}

- (void)button2Event:(UIButton *)button {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *lottieUrl = @"http://o.yinliqu.com/default/e5e9ab385df64b5b8ee63c1e85362ada.json";
        [self loadWithUrl:lottieUrl];
    });
}

- (void)button3Event:(UIButton *)button {
    DraggableCardController *controller = [[DraggableCardController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)sliderValueChange:(UISlider *)slider {
    NSLog(@"slider.value = %f",slider.value);
//    UIImage *image = [self.lottieLoader imageWithProgress:slider.value];
//    self.imgView.image = image;
    
    
  
    CVPixelBufferRef buffer = [[LottieLoaderManager shareInstance] pixelBufferWithProgress:slider.value];
    if (buffer) {
        self.imgView.image = [ImageConvertor imageFromPixelBuffer:buffer];
    }
}

- (void)loadWithUrl:(NSString *)url {
    FileManager *manager = [FileManager shareInstance];
    NSString *lottieUrl = url;
    NSString *lottieFileName = [lottieUrl componentsSeparatedByString:@"/"].lastObject;
    __block NSString *blockPath;
    NSLog(@"file before block");
    [manager resourcePathWithType:FilePathTypeFaceBox foldName:@"Lottie" fileName:lottieFileName url:lottieUrl complete:^(NSString * _Nonnull path) {
        NSLog(@"file finish：%@",path);
        blockPath = path;
    }];
    NSLog(@"file after block");
    [[LottieLoaderManager shareInstance] loadWithPath:blockPath url:lottieUrl];
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
    
    self.imgView = [[UIImageView alloc]init];
    self.imgView.userInteractionEnabled = false;
    [self.view addSubview:_imgView];
    _imgView.frame = CGRectMake(10, 90, 150, 150/(640/480.0));
    _imgView.layer.borderWidth = 1;
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"摇摆" ofType:@"json"];
//    LOTComposition *composition = [LOTComposition animationWithFilePath:path];
//    self.lottieView = [[LOTAnimationView alloc]initWithModel:composition inBundle:[NSBundle mainBundle]];
////    [self.view addSubview:self.lottieView];
//    self.lottieView.frame = CGRectMake(0, _imgView.bottom + 10, KScreenWidth, KScreenWidth);
//    self.lottieView.userInteractionEnabled = false;
//    [self.lottieView setAnimationProgress:0.2];
//    [self.view addSubview:self.lottieView];
    
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
