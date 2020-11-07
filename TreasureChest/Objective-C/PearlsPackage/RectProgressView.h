//
//  RectProgressView.h
//  TreasureChest
//
//  Created by jf on 2020/11/7.
//  Copyright © 2020 xiao ming. All rights reserved.
//  矩形进度条

#import <UIKit/UIKit.h>
#define KCycleLineWidth 2
#define KCycelLineColor [UIColor hexColor:@"#CBCBCB"]
#define KCycelLineCornerRadius 5

NS_ASSUME_NONNULL_BEGIN

@interface RectProgressView : UIView

- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end;       //!< 默认1秒
- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end duration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
