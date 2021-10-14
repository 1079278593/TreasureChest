//
//  UIView+Animation.m
//  Poppy_Dev01
//
//  Created by ming on 2020/9/7.
//  Copyright © 2020 xiao ming. All rights reserved.
//  可参考内定属性key：https://blog.csdn.net/u011960171/article/details/79470802

#import "UIView+Animation.h"

@implementation UIView (Animation)

///角度[-1, 1];
- (void)rotationAnimationWithDuration:(CGFloat)duration rotaionAngle:(CGFloat)angle repeatCount:(int)repeatCount {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:-angle];
    animation.toValue = [NSNumber numberWithFloat:angle];
    animation.duration = duration;
    animation.repeatCount = repeatCount;//CGFLOAT_MAX;
    animation.autoreverses = YES;
    [self.layer addAnimation:animation forKey:@"animateLayer"];
}

- (void)shakeAnimationWithDuration:(CGFloat)duration rotaionAngle:(CGFloat)angle animationType:(ShakeAnimationType)type isRepeat:(BOOL)isRepeat {
    [CATransaction begin];
    [self.layer removeAllAnimations];//先移除
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    switch (type) {
        case ShakeAnimationTypeLiner:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;
        case ShakeAnimationTypeEaseIn:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case ShakeAnimationTypeEaseOut:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        case ShakeAnimationTypeEaseInOut:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;
        default:
            break;
    }
    
    //左右摇摆弧度(0~pi为周期)不断减小的过程，看被除数就知道了(相当于多对：CABasicAnimation的frmoValue和toValue。)
    animation.values = @[@(-duration), @(duration), @(-duration/2.0), @(duration/2.0), @(-duration/4.0), @(duration/4.0), @(-duration/8.0), @(duration/8.0), @0.0, @0.0];
    animation.duration = duration;
    animation.repeatCount = CGFLOAT_MAX;
    animation.autoreverses = YES;
    [self.layer addAnimation:animation forKey:@"shake"];
    
    [CATransaction commit];
}

- (void)shakeXAnimationWithDuration:(CGFloat)duration shakeDirection:(ShakeDirection)direction animationType:(ShakeAnimationType)type completion:(void (^)(void))completionBlock {
    
    [CATransaction begin];
    
    CAKeyframeAnimation *animation;
    switch (direction) {
        case ShakeDirectionH:
            animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            break;
        case ShakeDirectionV:
            animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];//rotation
            break;
        default:
            break;
    }
    
    switch (type) {
        case ShakeAnimationTypeLiner:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;
        case ShakeAnimationTypeEaseIn:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case ShakeAnimationTypeEaseOut:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        case ShakeAnimationTypeEaseInOut:
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;
        default:
            break;
    }

    [CATransaction setCompletionBlock:completionBlock];
    animation.duration = duration;
    animation.values = @[@-20.0, @20.0, @-20.0, @20.0, @-10.0, @10.0, @-5.0, @5.0, @0.0];
    [self.layer addAnimation:animation forKey:@"shake"];
    
    [CATransaction commit];
}

@end
