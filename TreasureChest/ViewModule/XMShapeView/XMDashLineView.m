//
//  XMDashLineView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "XMDashLineView.h"
#define LengthsCount 5

@interface XMDashLineView() {
    CGFloat lengths[LengthsCount];
}

@property(assign, nonatomic)NSInteger dashCount;

@end

@implementation XMDashLineView

- (instancetype)init {
    if(self == [super init]){
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setLengthArray:(NSArray<NSNumber *> *)lengthArray {
    _lengthArray = lengthArray;
    _dashCount = MIN(lengthArray.count, LengthsCount);
    for (int i = 0; i<_dashCount; i++) {
        lengths[i] = lengthArray[i].intValue;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGPoint endPoint = CGPointMake(rect.size.width, 0);
    CGFloat lineWidth = self.lineWidth;
    UIColor *color = self.strokeColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context,kCGLineCapButt);
    CGContextSetLineDash(context, 0, lengths, _dashCount);
    [color set];

    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);//3.绘制
}


@end
