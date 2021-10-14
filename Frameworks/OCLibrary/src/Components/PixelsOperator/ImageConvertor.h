//
//  ImageConvertor.h
//  Poppy_Dev01
//
//  Created by jf on 2020/12/23.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

NS_ASSUME_NONNULL_BEGIN

@interface ImageConvertor : NSObject

+ (CVPixelBufferRef)pixelBufferFasterFromImage:(UIImage *)image;
+ (CVPixelBufferRef)pixelBufferFasterFromImageData:(void *)data size:(CGSize)size sizePerRow:(size_t)sizePerRow;
+ (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image;

+ (CVPixelBufferRef)pixelBufferFromLayer:(CALayer *)layer;
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer;//逆时针90度。
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer frameSize:(CGSize)frameSize;//逆时针90度。

+ (UIImage *)imageFromPixelBuffer:(CVImageBufferRef)imageBuffer;
+ (UIImage *)imageFromLayer:(CALayer *)layer frameSize:(CGSize)frameSize;

//打印：亮度值
//+ (int *)loadBrightnessWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
