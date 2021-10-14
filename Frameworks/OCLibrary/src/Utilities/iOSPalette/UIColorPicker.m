//
//  UIColorPicker.m
//  Poppy_Dev01
//
//  Created by jf on 2020/7/28.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "UIColorPicker.h"
#import "UIImage+Palette.h"

@interface UIColorPicker () {
    CGContextRef _imageContext;
    UInt32 *_pixels;
    NSUInteger width;
    NSUInteger height;
}


@end

@implementation UIColorPicker

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

- (instancetype)initWithImage:(UIImage *)image {
    if(self == [super init]){
        [self pixelsFromImage:image];
    }
    return self;
}

- (void)pixelsFromImage:(UIImage *)image {
    CGImageRef inputCGImage = [image CGImage];
    width = CGImageGetWidth(inputCGImage);
    height = CGImageGetHeight(inputCGImage);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    _pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    _imageContext = CGBitmapContextCreate(_pixels, width, height,
                                                 bitsPerComponent, bytesPerRow,
                                                 CGColorSpaceCreateDeviceRGB(),
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(_imageContext, CGRectMake(0, 0, width, height), inputCGImage);
}

- (void)dealloc
{

    //_pixels是否也要释放。
    NSLog(@"UIColorPicker dealloc");
    CGContextRelease(_imageContext);
    free(_pixels);
    //
    /*
     *关于颜色空间是否要释放
     
     问答：（基本意思就是不用释放，因为你并没有retain相关的操作）
     (As the API docs say, you are responsible for retaining and releasing the color space as necessary. I.e. if you need, retain it. If you do not retain, don't release)
     https://www.it1352.com/518203.html
     
     苹果官方对释放的解释：
     https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFMemoryMgmt/Concepts/Ownership.html
     */
}

#pragma mark - < 颜色获取 >
- (UIColor *)colorFromPoint:(CGPoint)point {
    if (point.x < 0 || point.y < 0) {
        return nil;
    }
    if ((NSUInteger)point.x > width || (NSUInteger)point.y > height) {
        return nil;
    }
    NSUInteger offset = (NSUInteger)point.y * width + (NSUInteger)point.x;
    if (offset > (width * height)) {//2020年08月03日14:34:13 这里还是存在越界可能。所以增加这个
        return [UIColor clearColor];
    }
    
    UInt32 * currentPixel = _pixels;
    currentPixel += offset;
    UInt32 color = *currentPixel;
    return [UIColor colorWithRed:R(color)/255.0 green:G(color)/255.0 blue:B(color)/255.0 alpha:A(color)/255.0];
}

+ (UIColor *)colorFromImage:(UIImage *)image point:(CGPoint)point {
    
    CGImageRef inputCGImage = [image CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 *pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
                                                 bitsPerComponent, bytesPerRow,
                                                 CGColorSpaceCreateDeviceRGB(),
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    //和上面的方法有点重复，可以优化
    if (point.x < 0 || point.y < 0) {
        return nil;
    }
    if ((NSUInteger)point.x > width || (NSUInteger)point.y > height) {
        return nil;
    }
    
    UInt32 * currentPixel = pixels;
    currentPixel += (NSUInteger)point.y * width + (NSUInteger)point.x;
    UInt32 color = *currentPixel;
    return [UIColor colorWithRed:R(color)/255.0 green:G(color)/255.0 blue:B(color)/255.0 alpha:A(color)/255.0];
    
}

#pragma mark - < 背景色获取 >

+ (UIColor *)backgroundColor:(UIImage *)image {
    
    
    
    return nil;
}
@end
