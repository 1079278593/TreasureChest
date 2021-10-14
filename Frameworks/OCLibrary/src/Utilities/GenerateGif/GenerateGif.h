//
//  GenerateGif.h
//  ARCamera
//
//  Created by ming on 2021/9/21.
//

#import <Foundation/Foundation.h>
#import "ImageConvertor.h"//用于压缩图片

NS_ASSUME_NONNULL_BEGIN

@interface GenerateGif : NSObject

///gifRate代表，每秒取几帧。
+ (NSArray *)separateGifImagesFromVideoPath:(NSString *)path gifRateCount:(int)gifRateCount maxLength:(CGFloat)maxLength;
+ (NSString *)generateGifWithImages:(NSArray *)images interval:(CGFloat)interval;

@end

NS_ASSUME_NONNULL_END
