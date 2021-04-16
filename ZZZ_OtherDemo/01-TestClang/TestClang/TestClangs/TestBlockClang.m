//
//  TestBlockClang.m
//  TestClang
//
//  Created by ming on 2021/4/6.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "TestBlockClang.h"

@interface TestBlockClang ()

@end

@implementation TestBlockClang

- (instancetype)init {
    if(self = [super init]){
        [self test];
    }
    return self;
}

#pragma mark - <  >
//转成c++后，定位代码位置，搜索：test_block_impl_0

int a = 1;
static int b = 2;
- (void)test {
    __block int c = 3;
    __block int c1 = 3;
    static int d = 4;
    NSMutableString *str = [[NSMutableString alloc]initWithString:@"hello"];
    void (^blk)(void) = ^{
        a++;b++;c++;d++;
        [str appendString:@"world"];
        NSLog(@"1----------- a = %d,b = %d,c = %d,d = %d,str = %@",a,b,c,d,str);
    };
        
    a++;b++;c++;d++;
    str = [[NSMutableString alloc]initWithString:@"haha"];
    NSLog(@"2----------- a = %d,b = %d,c = %d,d = %d,str = %@",a,b,c,d,str);
    blk();
    
    void (^blk1)(void) = [blk copy];
    blk1();
}

@end
