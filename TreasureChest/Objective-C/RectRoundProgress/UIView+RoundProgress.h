//
//  UIView+RoundProgress.h
//  TreasureChest
//
//  Created by jf on 2020/11/7.
//  Copyright © 2020 xiao ming. All rights reserved.
//  

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RoundProgress)

- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end duration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
