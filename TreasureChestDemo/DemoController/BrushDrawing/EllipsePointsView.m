//
//  EllipsePointsView.m
//  TreasureChest
//
//  Created by jf on 2020/8/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "EllipsePointsView.h"

@interface EllipsePointsView ()

@property(nonatomic, strong)NSMutableArray <UIView *> *pointViews;

@end

@implementation EllipsePointsView

/**
参考随机取点算法：https://blog.csdn.net/u014028063/article/details/84314780
例子，圆的随机分布

for i in range(1000):
    x = random.randint(0,100) - 50
    y = random.randint(0, 100) - 50
    if x*x + y*y < 50*50:
        x_values.append(x)
        y_values.append(y)
        
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if(self == [super initWithFrame:frame]){
        self.userInteractionEnabled = true;
        [self initDotView];
    }
    return self;
}

- (void)initDotView {
//    [self createBrushWithSize:CGSizeMake(self.width, self.height)];
//    [self createRect:self.size];
//    [self createEllipse:self.size];
}

- (float)getRandomFloat:(float)from to:(float)to {
    float diff = to - from;
    return (((float) arc4random() / UINT_MAX) * diff) + from;
}

- (void)createEllipse:(CGSize)brushSize {
    //设椭圆
    /**
     椭圆焦点在X轴上：x^2/a^2+y^2/b^2=1
     椭圆焦点在Y轴上：y^2/a^2+x^2/b^2=1  目前应该是这个
     
     a是半长轴长，bai就是原点到较远的顶点的距离。
     b是半du短轴长，就是原点到较近的zhi顶点的距dao离。
     椭圆是平面内到定点F1、F2的距离之和等于常数（大于|F1F2|）的动点P的轨迹，F1、F2称为椭圆的两个焦点。其数学表达式为：|PF1|+|PF2|=2a（2a>|F1F2|）
     */
    CGFloat pointWidth = 3;
    CGFloat area = brushSize.width * brushSize.height;
    CGFloat count = area/(pointWidth*pointWidth);
    count = MIN(150, count);
    
    for (int i = 0; i<count; i++) {
        CGFloat x = [self getRandomFloat:-brushSize.width/2.0 to:brushSize.width/2.0];
        CGFloat y = [self getRandomFloat:-brushSize.height/2.0 to:brushSize.height/2.0];
        CGFloat tmpY = pow(y, 2) / pow(brushSize.height/2.0, 2);
        CGFloat tmpX = pow(x, 2) / pow(brushSize.width/2.0, 2);//b是短的
        if ((tmpX + tmpY) <= 1) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 3, 3)];
            view.center = CGPointMake(x+brushSize.width/2.0, y+brushSize.height/2.0);
            [self.pointViews addObject:view];
            view.backgroundColor = [UIColor redColor];
            [self addSubview:view];
            NSLog(@"%d :%@",i,NSStringFromCGPoint(view.center));
        }
        
    }
}

- (void)createRect:(CGSize)brushSize {
    CGFloat pointWidth = 2;
    CGFloat area = brushSize.width * brushSize.height;
    CGFloat count = MIN(100, area/(pointWidth*pointWidth));
    
    for (int i = 0; i<count; i++) {
        CGFloat x = [self getRandomFloat:0 to:brushSize.width];
        CGFloat y = [self getRandomFloat:0 to:brushSize.height];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 2)];
        view.center = CGPointMake(x, y);
        [self.pointViews addObject:view];
        view.backgroundColor = [UIColor redColor];
        [self addSubview:view];
        NSLog(@"%d :%@",i,NSStringFromCGPoint(view.center));
    }
}

//这个效果比较好
- (void)createBrushWithSize:(CGSize)brushSize {

    self.pointViews = [NSMutableArray arrayWithCapacity:0];
    
    CGFloat ellipse_a = brushSize.width/2.0;           //a在Y轴上。
    CGFloat ellipse_b = brushSize.height/2.0;            //b在X轴上。
    CGFloat ellipse_length = 2*M_PI*ellipse_b + 4*(ellipse_a - ellipse_b);
    CGPoint originPoint = CGPointMake(ellipse_b, 0);    //可以调试随机起点。

    CGFloat baseRadiu = 6;//间隔弧长
    NSInteger suitableCount = ellipse_length / baseRadiu; //这里要再限制一下数量。
//    NSLog(@"%d",suitableCount);
    CGFloat theta = 2*M_PI / suitableCount;
    
    for (int j = 0; j<4; j++) {//围绕椭圆，构建多层，现在的有点不对，往里走，数量居然一样(作为随机偏移的另外一种方案？)
//        NSInteger subCount = suitableCount * 0.25*(j+1);
        NSInteger subCount = suitableCount;
        for (int i = 0; i<subCount; i++) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 2)];
            CGFloat x = (ellipse_a * (0.1+0.15*(j+1))) * cos(theta*i) + brushSize.width/2.0;
            CGFloat y = (ellipse_b * (0.1+0.15*(j+1))) * sin(theta*i) + brushSize.height/2.0;
            view.center = CGPointMake(x, y);
            [self.pointViews addObject:view];
            view.backgroundColor = [UIColor redColor];
            [self addSubview:view];
//            NSLog(@"椭圆点：%@",NSStringFromCGPoint(brushPoint.point));
            NSLog(@"%d :%@",i,NSStringFromCGPoint(view.center));
        }
    }
    
}

@end
