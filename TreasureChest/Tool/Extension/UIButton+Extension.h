//
//  UIButton+Extension.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonImageLayout){
    ImageLayoutTop,
    ImageLayoutLeft,
    ImageLayoutBottom,
    ImageLayoutRight
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Extension)

///padding是水平方向的，title和image的间距
- (void)imageAlignment:(ButtonImageLayout)style padding:(CGFloat)padding;

@end

NS_ASSUME_NONNULL_END
