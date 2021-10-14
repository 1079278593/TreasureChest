//
//  XMCircleView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "XMCircleView.h"

@implementation XMCircleView

- (instancetype)init {
    if(self == [super init]){
        _arcAngle = 1;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - < public method >
- (void)setArcAngle:(CGFloat)arcAngle {
    _arcAngle = arcAngle;
    [self setNeedsLayout];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    [super setLineWidth:lineWidth];
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [super setStrokeColor:strokeColor];
    [self setNeedsDisplay];
}

#pragma mark - <  >
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat radius = rect.size.width / 2.0;
    CGFloat lineWidth = self.lineWidth;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = self.arcAngle * (startAngle + M_PI * 2);
    UIColor *color = self.strokeColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);//设置线条的宽度
    CGContextSetLineCap(context,kCGLineCapButt);//设置线条的起始点样式

    CGFloat length[] = {3,8};//{a,b} 绘制a个像素，空b个像素，按照这个规则不断重复。
    CGContextSetLineDash(context, 0, length, 2);

    [color set];

    //startAngle值为0时，起始位置在：圆心的水平右侧。
    CGContextAddArc(context, radius , radius, radius-lineWidth/2.0, startAngle, endAngle, 0);//2.设置路径

    CGContextStrokePath(context);//3.绘制
}

@end
