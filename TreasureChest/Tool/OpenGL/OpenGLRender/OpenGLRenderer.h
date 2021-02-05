//
//  OpenGLRenderer.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/3.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "OpenGLProgram.h"

#define RETAINED_BUFFER_COUNT 6

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLRenderer : NSObject

@property(nonatomic, strong, readonly)EAGLContext *oldContext;
@property(nonatomic, strong, readonly)EAGLContext *oglContext;

// 这个属性必须实现，如果operatesInPlace值为NO，并且像素的输出比输入缓冲区有不同的格式描述。
// 如果outputFormatDescription非空，一旦渲染器已经准备好了就必须返回（复位后可以为空）
@property(nonatomic, readonly) CMFormatDescriptionRef __attribute__((NSObject)) outputFormatDescription;
@property(nonatomic, readonly) CVOpenGLESTextureRef __attribute__((NSObject)) dstTexture;
@property(nonatomic, readonly) CVOpenGLESTextureCacheRef __attribute__((NSObject)) inputCache;

//赋值这个：’切换‘program。放到内部，如果没有传，就用这个默认的。
@property(nonatomic, strong)OpenGLProgram *programGenerator;

//目前是输入输出大小一样，可能要增加输出比输入小的情况。
- (void)prepareForInputWithFormatDescription:(CMFormatDescriptionRef)inputFormatDescription;

///保留每次渲染结果：覆盖渲染。最后返回。
- (BOOL)startRender;
- (CVPixelBufferRef)finish;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
