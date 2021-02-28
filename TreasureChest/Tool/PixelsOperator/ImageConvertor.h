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

+ (CVPixelBufferRef)pixelBufferFromLayer:(CALayer *)layer;
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer;//逆时针90度。
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer frameSize:(CGSize)frameSize;//逆时针90度。

+ (UIImage *)imageFromPixelBuffer:(CVImageBufferRef)imageBuffer;
+ (UIImage *)imageFromLayer:(CALayer *)layer frameSize:(CGSize)frameSize;

@end

NS_ASSUME_NONNULL_END
