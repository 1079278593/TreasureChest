//
//  UIImage+Color.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/21.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Color)

//默认size(10,10)
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//绘制圆形

//绘制圆角

@end

NS_ASSUME_NONNULL_END
