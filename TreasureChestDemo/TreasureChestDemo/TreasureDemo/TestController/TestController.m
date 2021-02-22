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

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface TestController ()

@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIImageView *bgImgView;
@property(nonatomic, strong)UIImageView *frontImgView;

@property(nonatomic, strong)LOTAnimationView *lottieView;
@property(nonatomic, strong)UIImageView *imgView;

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
    [self showLottieWithProgress:0.2];
}

- (void)button3Event:(UIButton *)button {
    [self showLottieWithProgress:0.6];
}

- (void)showLottieWithProgress:(CGFloat)progress {
//    NSString *path = [self getDatas].firstObject;
    
    [self.lottieView setAnimationProgress:progress];
//    self.imgView.image = [self pixelBufferFromLayer:self.lottieView.layer];
    self.imgView.image = [self pixelBufferLeftLandscapeFromLayer:self.lottieView.layer];
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"摇摆" ofType:@"json"];
    LOTComposition *composition = [LOTComposition animationWithFilePath:path];
    self.lottieView = [[LOTAnimationView alloc]initWithModel:composition inBundle:nil];
//    [self.view addSubview:self.lottieView];
    self.lottieView.frame = CGRectMake(0, 80, 480, 640);
    self.lottieView.userInteractionEnabled = false;
    
    self.imgView = [[UIImageView alloc]init];
    self.imgView.userInteractionEnabled = false;
    [self.view addSubview:_imgView];
    _imgView.frame = CGRectMake(10, 90, 150, 150/(640/480.0));
    _imgView.layer.borderWidth = 1;
    
    LOTAnimationView *tmpLottieView = [[LOTAnimationView alloc]initWithModel:composition inBundle:nil];
    [self.view addSubview:tmpLottieView];
    tmpLottieView.frame = CGRectMake(10, _imgView.bottom + 10, _imgView.width, _imgView.height);
    tmpLottieView.userInteractionEnabled = false;
    [tmpLottieView setAnimationProgress:0.2];
}

- (NSArray *)getDatas {
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"lotties" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSArray *lotties = [bundle pathsForResourcesOfType:@"" inDirectory:@""];
    return lotties;
}

- (UIImage *)pixelBufferFromLayer:(CALayer *)layer {
    CGSize frameSize = CGSizeMake((int)layer.bounds.size.width,(int)layer.bounds.size.height);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES],
                             kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    /**
     UIKit － y轴向下
     Core Graphics(Quartz) － y轴向上
     OpenGL ES － y轴向上
     */
    CGContextTranslateCTM(context, 0, frameSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //调试:查看
    [layer renderInContext:context];
    UIImage *viewImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    return viewImage;
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    return pxbuffer;
}

//传入的layer比例为：480*640，要变成640*480
- (UIImage *)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer {
    CGSize frameSize = CGSizeMake((int)layer.bounds.size.height,(int)layer.bounds.size.width);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES],
                             kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    /**
     UIKit － y轴向下
     Core Graphics(Quartz) － y轴向上
     OpenGL ES － y轴向上
     */
    CGContextTranslateCTM(context, 0, frameSize.width);
    CGContextScaleCTM(context, 1.0, -1.0);//翻转后，原点变为左上角(原来为左下角),saveState
    
    CGContextRotateCTM(context, DEGREES_TO_RADIANS(-90));//旋转后，x和y轴颠倒
    CGContextTranslateCTM(context, -frameSize.width, frameSize.width*0);
    
    //调试查看
    [layer renderInContext:context];
    UIImage *viewImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    return viewImage;
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    return pxbuffer;
}
@end
