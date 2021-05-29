//
//  TestClang.m
//  TreasureChest
//
//  Created by ming on 2020/5/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestClang.h"
#import "objc/message.h"

@implementation TestClang

- (void)testStart {
    [self testBeInvoke:@""];
}

- (void)testBeInvoke:(NSString *)para {
    NSLog(@"%@",para);
}

@end
