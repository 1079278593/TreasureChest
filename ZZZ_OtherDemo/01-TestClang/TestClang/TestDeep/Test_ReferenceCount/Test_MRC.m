//
//  Test_MRC.m
//  TestClang
//
//  Created by ming on 2021/4/2.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "Test_MRC.h"

extern void _objc_autoreleasePoolPrint(void);

@interface Test_MRC ()

@end

@implementation Test_MRC

- (instancetype)init {
    if(self = [super init]){
        [self test];
    }
    return self;
}

- (void)test {
    //MRC下，持有概念是很弱的，非自己持有的也能释放
    id obj = [[NSObject alloc]init];
    id obj1 = obj;
    [obj1 release];
    
    //但是如果是加入了autorelease，就不能释放了
    id obj2 = [self testObjet];
    NSLog(@"1. autorelease count:%lu",(unsigned long)[obj2 retainCount]);
//    [obj2 release];
//    [obj2 release];
//    NSLog(@"2. autorelease count:%lu",(unsigned long)[obj2 retainCount]);
}

- (id)testObjet {
    _objc_autoreleasePoolPrint();//在头部声明 extern
    id obj = [[NSObject alloc]init];
    [obj autorelease];
    _objc_autoreleasePoolPrint();//在头部声明 extern
//    [obj autorelease];//打印发现不会重复添加。但是会crash
    _objc_autoreleasePoolPrint();
    return obj;
}

typedef void (^blk_t) (int count);

- (void)testBlock {
    blk_t blk = ^(int count) {

    };
    void *blk1 = (__bridge void *)Block_copy(blk);
    blk_t blk2 = Block_copy(blk);
}

@end
