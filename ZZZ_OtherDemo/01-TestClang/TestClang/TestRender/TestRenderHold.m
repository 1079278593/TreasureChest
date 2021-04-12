//
//  TestRenderHold.m
//  TestClang
//
//  Created by ming on 2021/4/10.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "TestRenderHold.h"
#import <UIKit/UIKit.h>

@interface TestRenderHold () <CALayerDelegate>

@end

@implementation TestRenderHold

- (instancetype)init {
    if(self = [super init]){

    }
    return self;
}

#pragma mark - < 绘制 >
/**
 首先，这个 delegate 一定不能是 UIView！因为 UIView 本身携带的 layer 的代理就是自己，如果你将一个 layer 的代理设置为它，它本身的 layer 就会受影响。通常会因为野指针而崩溃。

 其次，这个 delegate 也不能是 UIViewController，如果你将这个 VC push 出来，再 pop 回去，肯定也会崩溃的，原因也是野指针。不过这个野指针可能是由于 VC 先被释放了。
 */

//1.先调这一层
//- (void)displayLayer:(CALayer *)layer {
//    layer.backgroundColor = [UIColor cyanColor].CGColor;
//    UIImage *image = [UIImage imageNamed:@"memory"];
//    layer.contents = (id)image.CGImage;
//}

//如果displayLayer没有实现，回调这一层
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    //draw a thick red circle
    CGContextSetLineWidth(ctx, 10.0f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokeEllipseInRect(ctx, layer.bounds);
}

#pragma mark - < 动画 >

@end
