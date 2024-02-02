//
//  UIView+Extension.h
//  TreasureChest
//
//  Created by ming on 2019/12/19.
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

- (void)circle;
- (void)setCornerRadius:(CGFloat)cornerRadius;
- (void)setBorder:(UIColor *)color width:(CGFloat)width;

///可视化获取视图
+ (instancetype)viewForNib;
- (UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
