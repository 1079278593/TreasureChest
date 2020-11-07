//
//  RectProgressView.m
//  TreasureChest
//
//  Created by jf on 2020/11/7.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "RectProgressView.h"

@interface RectProgressView()

@property(nonatomic,strong)CAShapeLayer *cycleBackLayer;
@property(nonatomic,strong)CAShapeLayer *cycleFrontLayer;
@property(nonatomic,strong)CABasicAnimation *animation;

@property(nonatomic,assign)CGFloat progress;
@property(nonatomic,assign)CGSize cycleSize;

@end

@implementation RectProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _progress = 0.0f;
        _cycleSize = frame.size;
    
        self.cycleBackLayer.frame = CGRectMake(0, 0, _cycleSize.width, _cycleSize.height);
        self.cycleBackLayer.path = [self roundCornerPath:_cycleSize].CGPath;
        
        self.cycleFrontLayer.frame = CGRectMake(0, 0, _cycleSize.width, _cycleSize.height);
        self.cycleFrontLayer.path = [self roundCornerPath:_cycleSize].CGPath;
    }
    return self;
}

#pragma mark - < public >
- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end {
    [self startAnimation:start endProgress:end duration:1];
}

- (void)startAnimation:(CGFloat)start endProgress:(CGFloat)end duration:(CGFloat)duration {
    self.animation.fromValue  = [NSNumber numberWithFloat:start];
    _animation.toValue = [NSNumber numberWithFloat:end];
    _animation.duration = duration;
    
    _animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _animation.fillMode = kCAFillModeForwards;
    _animation.removedOnCompletion = NO;
    [self.cycleFrontLayer addAnimation:_animation forKey:@"strokeEndAnimation"];
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

#pragma mark - < init view >
- (CAShapeLayer *)cycleFrontLayer {
    if (_cycleFrontLayer == nil) {
        _cycleFrontLayer = [CAShapeLayer layer];
        _cycleFrontLayer.lineWidth = KCycleLineWidth;
        _cycleFrontLayer.strokeColor = KCycelLineColor.CGColor;
        _cycleFrontLayer.fillColor = [UIColor clearColor].CGColor;
        _cycleFrontLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:_cycleFrontLayer];
    }
    return _cycleFrontLayer;
}

- (CAShapeLayer *)cycleBackLayer {
    if (_cycleBackLayer == nil) {
        _cycleBackLayer = [CAShapeLayer layer];
        _cycleBackLayer.lineWidth = KCycleLineWidth;
        _cycleBackLayer.strokeColor = [UIColor hexColor:@"#FFF031"].CGColor;
        _cycleBackLayer.fillColor = [UIColor clearColor].CGColor;
        _cycleBackLayer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:_cycleBackLayer];
    }
    return _cycleBackLayer;
}

- (CABasicAnimation *)animation {
    if (!_animation) {
        _animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    }
    return _animation;
}

@end
