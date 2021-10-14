//
//  UIView+RoundProgress.m
//  TreasureChest
//
//  Created by jf on 2020/11/7.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "UIView+RoundProgress.h"
#import "UIColor+Extension.h"

#define KCycleLineWidth 2
#define KCycelLineCornerRadius 5

@implementation UIView (RoundProgress) 

- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end duration:(CGFloat)duration {
    CAShapeLayer *cycleBackLayer = [self getLayerWithColor:[UIColor hexColor:@"#FFF031"]];
    CAShapeLayer *cycleFrontLayer = [self getLayerWithColor:[UIColor hexColor:@"#CBCBCB"]];
    [self.layer addSublayer:cycleBackLayer];
    [self.layer addSublayer:cycleFrontLayer];
    
    cycleBackLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    cycleBackLayer.path = [self roundCornerPath:self.frame.size].CGPath;
    
    cycleFrontLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    cycleFrontLayer.path = [self roundCornerPath:self.frame.size].CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue  = [NSNumber numberWithFloat:start];
    animation.toValue = [NSNumber numberWithFloat:end];
    animation.duration = duration;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    [cycleFrontLayer addAnimation:animation forKey:@"strokeEndAnimation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [cycleBackLayer removeFromSuperlayer];
        [cycleFrontLayer removeFromSuperlayer];
    });
}

#pragma mark - < private >
- (CAShapeLayer *)getLayerWithColor:(UIColor *)color {
    CAShapeLayer *cycleBackLayer = [CAShapeLayer layer];
    cycleBackLayer.lineWidth = KCycleLineWidth;
    cycleBackLayer.strokeColor = color.CGColor;
    cycleBackLayer.fillColor = [UIColor clearColor].CGColor;
    return cycleBackLayer;
}

- (UIBezierPath *)roundCornerPath:(CGSize)size {
    CGFloat cornerRadius = KCycelLineCornerRadius;
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(size.width/2, 0)];
    [path addLineToPoint:CGPointMake(size.width-cornerRadius, 0)];
    [path addQuadCurveToPoint:CGPointMake(size.width, cornerRadius) controlPoint:CGPointMake(size.width, 0)];                       //圆角
    [path addLineToPoint:CGPointMake(size.width, size.height-cornerRadius)];
    [path addQuadCurveToPoint:CGPointMake(size.width-cornerRadius, size.height) controlPoint:CGPointMake(size.width, size.height)]; //圆角
    [path addLineToPoint:CGPointMake(cornerRadius, size.height)];
    [path addQuadCurveToPoint:CGPointMake(0, size.height-cornerRadius) controlPoint:CGPointMake(0, size.height)];                   //圆角
    [path addLineToPoint:CGPointMake(0, cornerRadius)];
    [path addQuadCurveToPoint:CGPointMake(cornerRadius, 0) controlPoint:CGPointMake(0, 0)];                                         //圆角
    [path closePath];
    return path;
}

@end
