//
//  UIView+Animation.h
//  Poppy_Dev01
//
//  Created by jf on 2020/9/7.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ShakeDirection){
    ShakeDirectionH = 1,            //水平方向
    ShakeDirectionV,                //垂直方向
};

typedef NS_ENUM(NSUInteger, ShakeAnimationType){
    ShakeAnimationTypeLiner = 1,    //线性
    ShakeAnimationTypeEaseIn,       //
    ShakeAnimationTypeEaseOut,      //
    ShakeAnimationTypeEaseInOut,    //
};

@interface UIView (Animation)

- (void)shakeAnimationWithDuration:(CGFloat)duration rotaionAngle:(CGFloat)angle animationType:(ShakeAnimationType)type isRepeat:(BOOL)isRepeat;
- (void)rotationAnimationWithDuration:(CGFloat)duration rotaionAngle:(CGFloat)angle repeatCount:(int)repeatCount;

@end

NS_ASSUME_NONNULL_END

/**
 //        _Animation.fromValue = (__bridge id _Nullable)([UIColor redColor].CGColor);
 //        _Animation.toValue = (__bridge id _Nullable)([UIColor whiteColor].CGColor);
 */
