//
//  UIColor+UIImage.h
//  TreasureChest
//
//  Created by xiao ming on 2020/3/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (UIImage)

///矩形
- (UIImage *)imageWithSize:(CGSize)size;
- (UIImage *)image;

///圆形
- (UIImage *)imageWithRadius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
