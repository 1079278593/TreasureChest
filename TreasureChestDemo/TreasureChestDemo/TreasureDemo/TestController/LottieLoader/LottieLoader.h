//
//  LottieLoader.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/27.
//  Copyright © 2021 YLQTec. All rights reserved.
//
/**
 水果： http://o.yinliqu.com/default/741b4c9dea5747a995c6d0cd24dda2bd.json
 蝴蝶： http://o.yinliqu.com/default/e5e9ab385df64b5b8ee63c1e85362ada.json
 烟雾： http://o.yinliqu.com/default/4535e11bcda1477e85b94a87352234b2.json
 */
#import <Foundation/Foundation.h>
#import "TextureModel.h"

#define KLottieFrameRate 20  //每秒渲染20帧

@interface LottieLoader : NSObject

//path或者url如果无效，会创建失败
- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithUrl:(NSString *)url;

///返回逆时针旋转90的pixelBuffer
- (CVPixelBufferRef)pixelBufferWithProgress:(CGFloat)progress;
- (NSTimeInterval)getDuration;
- (void)clean;

///返回Image：目前调试用，
- (UIImage *)imageWithProgress:(CGFloat)progress;

@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *path;
@property(nonatomic, strong)NSMutableArray <TextureModel *> *buffers;

@end
