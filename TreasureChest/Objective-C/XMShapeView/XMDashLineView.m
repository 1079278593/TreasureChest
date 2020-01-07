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
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, lineWidth);//1.1 设置线条的宽度

    CGContextSetLineCap(context,kCGLineCapButt);//1.2 设置线条的起始点样式

    CGContextSetLineDash(context, 0, lengths, _dashCount);

    [[UIColor redColor] set];//1.4 设置颜色
dfasfds待完善：颜色、或者其他。
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);//3.绘制
}


@end
