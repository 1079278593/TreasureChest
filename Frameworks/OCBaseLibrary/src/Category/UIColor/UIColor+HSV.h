//
//  UIColor+HSV.h
//  Poppy_Dev01
//
//  Created by xiao ming on 2020/7/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface UIColor (HSV)

///将UIColor转HSV
- (void)ColorToHSV:(CGFloat *)hue s:(CGFloat *)saturation v:(CGFloat *)brightness;

@end



NS_ASSUME_NONNULL_END
