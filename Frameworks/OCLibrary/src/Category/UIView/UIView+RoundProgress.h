//
//  UIView+RoundProgress.h
//  TreasureChest
//
//  Created by ming on 2020/11/7.
//  Copyright © 2020 xiao ming. All rights reserved.
//  

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RoundProgress)

///矩形：传入后，立马开始动画
- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end duration:(CGFloat)duration;

///圆形：传入后，立马开始动画
- (void)startCircleAnimation:(CGFloat)start endProgress:(CGFloat)end duration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
