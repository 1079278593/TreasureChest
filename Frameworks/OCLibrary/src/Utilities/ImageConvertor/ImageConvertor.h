//
//  ImageConvertor.h
//  Poppy_Dev01
//
//  Created by jf on 2020/12/23.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageConvertor : NSObject

+ (CVPixelBufferRef)pixelBufferFasterFromImage:(UIImage *)image;
+ (CVPixelBufferRef)pixelBufferFasterFromImageData:(void *)data size:(CGSize)size sizePerRow:(size_t)sizePerRow;
+ (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image;
+ (CVPixelBufferRef)pixelBufferFromImage1:(UIImage *)image;//给’遮罩‘用
+ (CVPixelBufferRef)pixelBufferFromMatData:(void *)data;//待完成

+ (CVPixelBufferRef)pixelBufferFromLayer:(CALayer *)layer;
//逆时针90度。
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer;
///传入的layer比例为：480*640，要变成640*480
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer frameSize:(CGSize)frameSize;

+ (UIImage *)imageFromPixelBuffer:(CVImageBufferRef)imageBuffer;
+ (UIImage *)imageFromPixelBufferWithRotation90:(CVImageBufferRef)imageBuffer;//!< 顺时针旋转90度
+ (UIImage *)imageRotate:(UIImage *)image;
+ (UIImage *)debugImageFromMatData;//调试

+ (void *)matDataFromImage:(UIImage *)image;

+ (UIImage *)scaleImage:(UIImage *)imgage maxLength:(CGFloat)length;

+ (CVPixelBufferRef)pixelBufferFaster:(CVPixelBufferRef) imageBuffer;

@end

NS_ASSUME_NONNULL_END
