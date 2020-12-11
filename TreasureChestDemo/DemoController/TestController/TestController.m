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
    
    [self initView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.layer.borderWidth = 1;
    [_button setTitle:@"切换按钮" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.frame = CGRectMake(220, 120, 90, 44);
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"1" ofType:@"bytes"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    
//    UIImage *image= [UIImage imageWithData:data];
    UIImage *image= [UIImage imageNamed:@"bgPic"];
    NSUInteger width = CGImageGetWidth([image CGImage]);
    NSUInteger height = CGImageGetHeight([image CGImage]);
    
    //提取void *data
    CGDataProviderRef provider = CGImageGetDataProvider([image CGImage]);
    void *byteData =(void*) CFDataGetBytePtr(CGDataProviderCopyData(provider));
    
    //转为bgr的image
    UIImage *bgrImage = [self loadBGRAImage:image width:width height:height];
    
    //转为nsdata
    NSData *bgrData = UIImageJPEGRepresentation(bgrImage, 1);
    
    
    self.bgImgView.image = [UIImage imageWithData:bgrData];
    
//    UIImage *newImage = [UIImage imageWithData:[self getBGRWithImage:image]];
//    self.bgImgView.image = newImage;
    
    
    
//    self.bgImgView.image = image;
//    [NSData dataWithBytes:<#(nullable const void *)#> length:<#(NSUInteger)#>]
}

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
//pixelBuffers为：RGB
- (UIImage *)loadBGRAImage:(UIImage *)inputImage width:(NSUInteger)width height:(NSUInteger)height {
    // 1. Get the raw pixels of the image
    UInt32 * inputPixels;
    
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    for (NSUInteger j = 0; j < height; j++) {
        for (NSUInteger i = 0; i < width; i++) {
            NSUInteger offset = j * width + i;
            UInt32 *inputPixel = inputPixels + offset;
            UInt32 inputColor = *inputPixel;
            
            UInt32 newR = R(inputColor);
            UInt32 newG = G(inputColor);
            UInt32 newB = B(inputColor);
            
            newR = MAX(0,MIN(255, newR));
            newG = MAX(0,MIN(255, newG));
            newB = MAX(0,MIN(255, newB));
            UInt32 resultColor = RGBAMake(newB, newG, newR, 255);
            *inputPixel = resultColor;
        }
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return resultImage;
}

- (NSData *)getBGRWithImage:(UIImage *)image
{
    int RGBA = 4;
    int RGB  = 3;
    
    CGImageRef imageRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    char *m = (char *)malloc(sizeof(char)*100);
    m[0] = "3";
    m[1] = "43";
    m[2] = "53";
    unsigned char *rawData = (unsigned char *) malloc(width * height * sizeof(unsigned char) * RGBA);
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    unsigned char * tempRawData = (unsigned char *)malloc(width * height * 3 * sizeof(unsigned char));
    
    for (int i = 0; i < width * height; i ++) {
        
        NSUInteger byteIndex = i * RGBA;
        NSUInteger newByteIndex = i * RGB;
        
        // Get RGB
        CGFloat red    = rawData[byteIndex + 0];
        CGFloat green  = rawData[byteIndex + 1];
        CGFloat blue   = rawData[byteIndex + 2];
        //CGFloat alpha  = rawData[byteIndex + 3];// 这里Alpha值是没有用的
        
        // Set RGB To New RawData
        tempRawData[newByteIndex + 0] = blue;   // B
        tempRawData[newByteIndex + 1] = green;  // G
        tempRawData[newByteIndex + 2] = red;    // R
    }
    
    NSData *data = [NSData dataWithBytes:tempRawData length:(width * height * 3 * sizeof(unsigned char))];
    return data;
}

#pragma mark - < init view >
- (void)initView {
    _bgImgView = [[UIImageView alloc]init];
    _bgImgView.image = [UIImage imageNamed:@"bgPic"];
    [self.view addSubview:_bgImgView];
    _bgImgView.frame = self.view.bounds;
}

@end
