//
//  OpenGLFaceMaskRender.h
//  Poppy_Dev01
//
//  Created by jf on 2020/10/17.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "VertexGenerator.h"

NS_ASSUME_NONNULL_BEGIN

#define RETAINED_BUFFER_COUNT 6

@interface OpenGLRender : NSObject

// 这个属性必须实现，如果operatesInPlace值为NO，并且像素的输出比输入缓冲区有不同的格式描述。
// 如果outputFormatDescription非空，一旦渲染器已经准备好了就必须返回（复位后可以为空）
@property(nonatomic, readonly) CMFormatDescriptionRef __attribute__((NSObject)) outputFormatDescription;

- (void)prepareForInputWithFormatDescription:(CMFormatDescriptionRef)inputFormatDescription;

- (CVPixelBufferRef)renderFaceMaskToPixelBuffer:(CVPixelBufferRef)pixelBuffer generator:(VertexGenerator *)vertexGenerator;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
