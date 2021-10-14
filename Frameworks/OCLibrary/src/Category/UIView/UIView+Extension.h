//
//  UIView+Extension.h
//  TreasureChest
//
//  Created by ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define IsPhoneX KScreenWidth >=375.0f && KScreenHeight >= 812.0f

#define KScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define KScreenWidth  ([[UIScreen mainScreen] bounds].size.width)

#define KStatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)   //!< 刘海屏44，其它20
#define KStatusBarHeightNormal (20)    //
#define KNaviBarHeight (44)
#define KTopBarSafeHeight KStatusBarHeight + KNaviBarHeight

#define KTabBarHeight (CGFloat)(IsPhoneX ? (49.0 + 34.0) : (49.0))
#define KBottomSafeHeight (CGFloat)(IsPhoneX?(34.0):(0))

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
