//
//  UIView+Extension.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

///设置圆角
- (void)setCornerRadius:(CGFloat)cornerRadius;

///设置成圆
- (void)cornerRadius;

///设置边框
- (void)setBorder:(UIColor *)color width:(CGFloat)width;

///可视化获取视图
+ (instancetype)viewForNib;

@end

NS_ASSUME_NONNULL_END
