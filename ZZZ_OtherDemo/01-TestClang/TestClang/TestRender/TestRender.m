//
//  TestRender.m
//  TestClang
//
//  Created by ming on 2021/4/10.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "TestRender.h"
#import "TestRenderHold.h"
#import "InterpolateGenerator.h"

@interface TestRender () 

@property(nonatomic, strong)TestRenderHold *renderHold;
@property(nonatomic, strong)CALayer *testLayer;

@end

@implementation TestRender

- (instancetype)init {
    if(self = [super init]){
        [self setupSubview];
    }
    return self;
}

#pragma mark - < public >
- (void)testRenderMethod1 {
    
}

#pragma mark - < event >
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //get the touch point
    CGPoint point = [[touches anyObject] locationInView:self];
    //check if we've tapped the moving layer
    if ([self.testLayer.presentationLayer hitTest:point]) {
        //randomize the layer background color
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat green = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
        self.testLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
    } else {
        //1.隐式动画方式
//        [CATransaction begin];
//        [CATransaction setAnimationDuration:4.0];
//        self.testLayer.position = point;
//        [CATransaction commit];
        
        //2.显示动画
        [self.testLayer removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.duration = 4;
//        animation.fillMode = kCAFillModeBackwards;
//        animation.fillMode = kCAFillModeForwards;
        animation.fillMode = kCAFillModeBoth;
        animation.removedOnCompletion = NO;
        animation.keyPath = @"position";
        animation.toValue = (id)[NSValue valueWithCGPoint:CGPointMake(200, 200)];
        [self.testLayer addAnimation:animation forKey:nil];
        
    }
}

/**
 目的是观察：隐式动画和显示动画的modelLayer的值，是初始状态还是结束状态。
 其中：隐式动画是结束状态，显示动画如果没有任何设置是初始状态。
 如果：设置removedOnCompletion=NO，并且设置fillMode。
 结果：显示动画不管怎么设置modelLayer都是值都是初始值，而presentationLayer始终保持和界面的值一致(变化到哪，值就跟着变化)
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *modelLayerPoint = NSStringFromCGPoint(self.testLayer.modelLayer.frame.origin);
    NSString *presentLayerPoint = NSStringFromCGPoint(self.testLayer.presentationLayer.frame.origin);
    NSLog(@"modelLayerPoint:%@",modelLayerPoint);
    NSLog(@"presentLayerPoint:%@\n",presentLayerPoint);
}

#pragma mark - < private >
//验证modelLayer和presentLayer
- (void)testShowLayer {
    CALayer *testLayer = [[CALayer alloc]init];
//    testLayer.delegate = self.renderHold;
    testLayer.frame = CGRectMake(20, 0, 100, 100);
    testLayer.contents = (__bridge id)[UIImage imageNamed:@"memory"].CGImage;//这里设置无效
    testLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:testLayer];
    //需要显式地调用-display。不同于UIView，当图层显示在屏幕上时，CALayer不会自动重绘它的内容。它把重绘的决定权交给了开发者。
    [testLayer display];
    self.testLayer = testLayer;
}

//阴影
- (void)testShowShadow {
    UIImageView *img = [[UIImageView alloc]init];
    img.image = [UIImage imageNamed:@"award_box_open"];
    [self addSubview:img];
    img.frame = CGRectMake(130, 0, 100, 100);
    
    //如果是图片，不设置背景色：可以看到内容的阴影
//    img.backgroundColor = [UIColor whiteColor];
    img.layer.shadowOffset = CGSizeMake(0, 1);
    img.layer.shadowRadius = 4;
    img.layer.shadowOpacity = 0.9;
    img.layer.shadowColor = [UIColor blackColor].CGColor;
    
    //如果有子视图也会加上阴影，牛逼。
    UIView *tmpView = [[UIView alloc]init];
    tmpView.frame = CGRectMake(10, 10, 10, 10);
    tmpView.backgroundColor = [UIColor redColor];
    [img addSubview:tmpView];
}

//重新采样
- (void)testFilter {
    UIImageView *img = [[UIImageView alloc]init];
    img.image = [UIImage imageNamed:@"test_filter"];//37*30
    [self addSubview:img];
    img.frame = CGRectMake(20, 110, 50, 50);
    
    //kCAFilterLinear,kCAFilterNearest,kCAFilterTrilinear
//    self.layer.minificationFilter = kCAFilterLinear;
    img.layer.magnificationFilter = kCAFilterLinear;//好像差别不大，kCAFilterNearest比较明显
}

#pragma mark < 缓冲 >
/**
 除了+functionWithName:之外，CAMediaTimingFunction同样有另一个构造函数，一个有四个浮点参数的+functionWithControlPoints::::,可以定义两个控制点的x，y分别是cp1x,cp1y,cp2x,cp2y。CAMediaTimingFunction有一个叫做-getControlPointAtIndex:values:的方法，可以用来检索曲线的点。注意values:用浮点数组接收，不是CGPoint。index是从0-3的整数，0,3代表起点和终点，1,2代表起点和终点的控制点。self.layerView.layer.geometryFlipped = YES可以使坐标的原点在左下角，起点和终点的坐标是(0,0)和(1,1)。
 */
- (void)showSystemBezierPath {
//    [self showCustomBezierPath];return;
    CALayer *testLayer = [[CALayer alloc]init];
    testLayer.frame = CGRectMake(20, 150, 200, 200);
    testLayer.backgroundColor = [UIColor cyanColor].CGColor;
    [self.layer addSublayer:testLayer];
    
    //create timing function：[(0,0), c1, c2, (1,1)]，下面4个数组成c1和c2
//    CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithControlPoints:1 :0.4 :0.75 :1];
    
    //get control points
    float cp1[2],cp2[2];
    [function getControlPointAtIndex:1 values:cp1];
    [function getControlPointAtIndex:2 values:cp2];

    CGPoint controlPoint1,controlPoint2;
    controlPoint1 = CGPointMake(cp1[0], cp1[1]);
    controlPoint2 = CGPointMake(cp2[0], cp2[1]);
    //create curve
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointZero];
    [path addCurveToPoint:CGPointMake(1, 1)
            controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    //scale the path up to a reasonable size for display
    [path applyTransform:CGAffineTransformMakeScale(200, 200)];
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 4.0f;
    shapeLayer.path = path.CGPath;
    [testLayer addSublayer:shapeLayer];
    //flip geometry so that 0,0 is in the bottom-left
    testLayer.geometryFlipped = YES;
}

#pragma mark < 自定义缓冲动画 >
- (void)customPathAnimate {
    CALayer *testLayer = [[CALayer alloc]init];
    testLayer.frame = CGRectMake(20, 150, 20, 20);
    testLayer.backgroundColor = [UIColor yellowColor].CGColor;
    [self.layer addSublayer:testLayer];
    
    //reset ball to top of screen
    testLayer.position = CGPointMake(60, 150);
    //set up animation parameters
    NSValue *fromValue = [NSValue valueWithCGPoint:CGPointMake(60, 150)];
    NSValue *toValue = [NSValue valueWithCGPoint:CGPointMake(60, 250)];
    CFTimeInterval duration = 3.0;
    //generate keyframes
    NSInteger numFrames = duration * 60;
    NSMutableArray *frames = [NSMutableArray array];
    for (int i = 0; i < numFrames; i++) {
        float time = 1/(float)numFrames * i;
        //apply easing
        time = bounceEaseOut(time);//线性转成非线性
        //add keyframe
        [frames addObject:[InterpolateGenerator interpolateFromValue:fromValue toValue:toValue time:time]];
    }
    //create keyframe animation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 3.0;
//    animation.delegate = self;
    animation.values = frames;
    //apply animation
    [testLayer addAnimation:animation forKey:nil];
}

#pragma mark - < init view >
- (void)setupSubview {
    [self testShowLayer];
    [self testShowShadow];
    [self testFilter];
    [self showSystemBezierPath];
    [self customPathAnimate];
}

- (TestRenderHold *)renderHold {
    if (_renderHold == nil) {
        _renderHold = [[TestRenderHold alloc]init];
    }
    return _renderHold;
}

@end
