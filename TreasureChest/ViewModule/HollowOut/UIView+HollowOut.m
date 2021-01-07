//
//  UIView+HollowOut.m
//  TreasureChest
//
//  Created by ming on 2020/11/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "UIView+HollowOut.h"

@implementation UIView (HollowOut)

- (void)hollowOutWithRect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:rect] bezierPathByReversingPath]];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = maskPath.CGPath;
        
    self.layer.mask = shapeLayer;
}

@end
