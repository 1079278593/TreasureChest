//
//  TestActionProgressAction.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/17.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestActionProgressAction.h"

@implementation TestActionProgressAction

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict{
    CALayer *layer = anObject;
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration=3;
    animation.fromValue=[NSNumber numberWithFloat:self.oldValue/100.0];
    animation.toValue=[NSNumber numberWithFloat:[[layer valueForKey:event] floatValue]/100.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"strokeEnd"];
}

@end
