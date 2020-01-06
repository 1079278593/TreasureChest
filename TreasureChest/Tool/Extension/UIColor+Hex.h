//
//  UIColor+Hex.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/21.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

// 默认alpha位1
+ (UIColor *)hexColor:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)hexColor:(NSString *)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
