//
//  RuntimeApply.m
//  TestClang
//
//  Created by ming on 2021/5/3.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "RuntimeApply.h"
#import "NSArray+Boundary.h"

@implementation RuntimeApply

- (instancetype)init {
    if(self = [super init]){
        [self test];
    }
    return self;
}

#pragma mark - < private >
- (void)test {
    return;
    NSArray *arr = @[@3,@33,@535];
//    NSLog(@"%@",arr[53]);
    NSLog(@"%@",[arr objectAtIndex:43]);
}

@end

