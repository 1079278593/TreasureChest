//
//  WaveButton.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/2.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "WaveButton.h"
//#import "RoundWavesView.h"

@interface WaveButton ()

@property(nonatomic, strong)CAShapeLayer *line1Layer;
@property(nonatomic, strong)CAShapeLayer *lineDash2Layer;
@property(nonatomic, strong)CAShapeLayer *line3Layer;
@property(nonatomic, strong)CAShapeLayer *lineDash4Layer;

@property(nonatomic, strong)UIImageView *borderImgView;
@property(nonatomic, strong)UIImageView *faceImgView;

@end

@implementation WaveButton

- (instancetype)initWithFrame:(CGRect)frame {
    if(self == [super initWithFrame:frame]){
        [self initView];
//        _wavesView.userInteractionEnabled = NO;
        _faceImgView.userInteractionEnabled = NO;
    }
    return self;
}

#pragma mark - < public >
- (void)refreshWithImgPath:(NSString *)imgPath {
    [self.faceImgView sd_setImageWithURL:[NSURL URLWithString:imgPath]];
}

#pragma mark - < init view >
- (void)initView {
    CGFloat layerBorderWidth = 12;
    CGFloat width = self.width - 40;
    _borderImgView = [[UIImageView alloc]init];
    _borderImgView.layer.masksToBounds = YES;
    _borderImgView.layer.borderWidth = layerBorderWidth;
    _borderImgView.layer.borderColor = [[UIColor hexColor:@"#fd3893"] colorWithAlphaComponent:1.0].CGColor;
    _borderImgView.frame = CGRectMake(0, 0, width, width);
    _borderImgView.center = CGPointMake(self.width/2.0, self.height/2.0);
    _borderImgView.layer.cornerRadius = _borderImgView.height/2.0;
    [self addSubview:_borderImgView];
    
    width = width - layerBorderWidth*2 - 4;
    _faceImgView = [[UIImageView alloc]init];
    _faceImgView.image = [UIImage imageNamed:@"face2"];
    _faceImgView.layer.masksToBounds = YES;
    _faceImgView.contentMode = UIViewContentModeScaleAspectFill;
    _faceImgView.frame = CGRectMake(0, 0, width, width);
    _faceImgView.center = CGPointMake(self.width/2.0, self.height/2.0);
    _faceImgView.layer.cornerRadius = _faceImgView.height/2.0;
    [self addSubview:_faceImgView];
    
    [self addWaveLayer];
    [self addAnimation];
}

#pragma mark - < wave layer >
- (void)addWaveLayer {
    UIColor *color = [UIColor hexColor:@"#fd3893"];
    CGFloat minRadius = _borderImgView.width/2.0;
    CGFloat maxRadius = self.width/2.0;
    CGFloat lineSpace = 2;
    
    CGFloat radius;
    CGFloat offsetX;
    
    //第1根实线
    radius = minRadius + lineSpace*0;
    offsetX = maxRadius - radius;
    self.line1Layer = [self getShapeLayer];
    self.line1Layer.strokeColor = color.CGColor;
    self.line1Layer.path = [self circlePathWithCenter:CGPointMake(radius, radius) radius:radius].CGPath;
    [self.layer addSublayer:self.line1Layer];
    self.line1Layer.frame = CGRectMake(offsetX, offsetX, radius*2, radius*2);
    
    //第2根虚线
    radius = minRadius + lineSpace*1;
    offsetX = maxRadius - radius;
    self.lineDash2Layer = [self getShapeLayer];
    self.lineDash2Layer.lineDashPattern = @[@2,@4];//绘制a个像素，空b个像素，按照这个规则不断重复。
    self.lineDash2Layer.strokeColor = color.CGColor;
    self.lineDash2Layer.path = [self circlePathWithCenter:CGPointMake(radius, radius) radius:radius+lineSpace*1].CGPath;
    [self.layer addSublayer:self.lineDash2Layer];
    self.lineDash2Layer.frame = CGRectMake(offsetX, offsetX, radius*2, radius*2);
    
    //第3根实线
    radius = minRadius + lineSpace*2;
    offsetX = maxRadius - radius;
    self.line3Layer = [self getShapeLayer];
    self.line3Layer.strokeColor = color.CGColor;
    self.line3Layer.path = [self circlePathWithCenter:CGPointMake(radius, radius) radius:radius+lineSpace*2].CGPath;
    [self.layer addSublayer:self.line3Layer];
    self.line3Layer.frame = CGRectMake(offsetX, offsetX, radius*2, radius*2);
    
    //第4根虚线
    radius = minRadius + lineSpace*3;
    offsetX = maxRadius - radius;
    self.lineDash4Layer = [self getShapeLayer];
    self.lineDash4Layer.lineDashPattern = @[@2,@4];//绘制a个像素，空b个像素，按照这个规则不断重复。
    self.lineDash4Layer.strokeColor = color.CGColor;
    self.lineDash4Layer.path = [self circlePathWithCenter:CGPointMake(radius, radius) radius:radius+lineSpace*3].CGPath;
    [self.layer addSublayer:self.lineDash4Layer];
    self.lineDash4Layer.frame = CGRectMake(offsetX, offsetX, radius*2, radius*2);
}

- (void)addAnimation {
    //先移除
    [self.line1Layer removeAllAnimations];
    [self.lineDash2Layer removeAllAnimations];
    [self.line3Layer removeAllAnimations];
    [self.lineDash4Layer removeAllAnimations];
    
    [CATransaction begin];

    NSArray *animations = [self combineGroupAnimation:WaveAnimationTypeLiner];
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = animations;
    groupAnimation.duration = 2;
    groupAnimation.removedOnCompletion = YES;
    groupAnimation.repeatCount = CGFLOAT_MAX;
    groupAnimation.autoreverses = YES;
    
    [self.line1Layer addAnimation:groupAnimation forKey:@"groupAnimation1"];
    [self.lineDash2Layer addAnimation:groupAnimation forKey:@"groupAnimation2"];
    [self.line3Layer addAnimation:groupAnimation forKey:@"groupAnimatio3"];
    [self.lineDash4Layer addAnimation:groupAnimation forKey:@"groupAnimatio4"];

    [CATransaction commit];
}

- (NSArray *)combineGroupAnimation:(WaveAnimationType)type {
    CAMediaTimingFunction *timingFunction;
    switch (type) {
        case WaveAnimationTypeLiner:
            timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;
        case WaveAnimationTypeEaseIn:
            timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case WaveAnimationTypeEaseOut:
            timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        case WaveAnimationTypeEaseInOut:
            timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;
        default:
            break;
    }
    
    //旋转
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.values = @[@(0), @(2)];//因为是旋转，所以value指代的是弧度
    rotationAnimation.timingFunction = timingFunction;
    
    //缩放
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.timingFunction = timingFunction;
    scaleAnimation.values = @[@(1), @(1.4)];//因为是缩放，所以value指代的是缩放倍数

    //透明度
    CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.values = @[@(1), @(0.4)];//透明度
    alphaAnimation.timingFunction = timingFunction;

    return @[rotationAnimation,scaleAnimation,alphaAnimation];
}

#pragma mark - < private >
- (CAShapeLayer *)getShapeLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 1;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineCap = kCALineCapRound;//在线段头尾添加半径为线段 lineWidth 一半的半圆
    return shapeLayer;
}

- (UIBezierPath *)circlePathWithCenter:(CGPoint)center radius:(CGFloat)radius {
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = (startAngle + M_PI * 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    return path;
}


#pragma mark - < 未使用 >
- (CAAnimationGroup *)getGroupAnimationWithAnimations:(NSArray *)animations speedType:(WaveAnimationType)type duration:(CGFloat)duration {
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = animations;
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.repeatCount = CGFLOAT_MAX;
    animation.autoreverses = YES;
//    animation.fillMode = kCAFillModeForwards;
    return animation;
}
@end
