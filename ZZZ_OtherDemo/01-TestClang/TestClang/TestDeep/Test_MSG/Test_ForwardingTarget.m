//
//  Test_ForwardingTarget.m
//  TreasureChest
//
//  Created by ming on 2020/5/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "Test_ForwardingTarget.h"

@implementation Test_ForwardingTarget

- (void)testBeInvoke:(NSString *)para {
    
}

//转发后，如果不能处理这个消息，也是走3步流程

//1...
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;
}
//2...
//3...
@end
