//
//  HollowOutView.m
//  TreasureChest
//
//  Created by ming on 2020/11/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "HollowOutView.h"

@interface HollowOutView ()



@end

@implementation HollowOutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        self.image = [UIImage imageNamed:@"bgPic1"];
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

#pragma mark - < init view >
- (void)initView {
    
    //mask的frame
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    //镂空区域1：圆形
//    [bpath appendPath:[UIBezierPath bezierPathWithArcCenter:self.center radius:100 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    //镂空区域2：矩形。关键：bezierPathByReversingPath
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(20, 180, 100, 100)] bezierPathByReversingPath]];
        
    //创建一个CAShapeLayer 图层
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = maskPath.CGPath;
        
    //添加图层蒙板
    self.layer.mask = shapeLayer;
}

@end
