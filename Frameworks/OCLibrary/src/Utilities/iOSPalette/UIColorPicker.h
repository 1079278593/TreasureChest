//
//  UIColorPicker.h
//  Poppy_Dev01
//
//  Created by jf on 2020/7/28.
//  Copyright © 2020 YLQTec. All rights reserved.
//  如果实时取颜色，还是要持有的方式才能保证性能

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColorPicker : NSObject

- (instancetype)initWithImage:(UIImage *)image;

//这里的point一定要从‘容器位置’映射到‘图片位置’
- (UIColor *)colorFromPoint:(CGPoint)point;
+ (UIColor *)colorFromImage:(UIImage *)image point:(CGPoint)point;

+ (UIColor *)backgroundColor:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
