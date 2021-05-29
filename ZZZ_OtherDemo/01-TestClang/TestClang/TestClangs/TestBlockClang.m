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
        [self testCopy];
    }
    return self;
}

#pragma mark - <  >
//转成c++后，定位代码位置，搜索：test_block_impl_0
//byref : 按地址

//第1层
int a = 1;
static int b = 2;

- (void)test {
    //第3层（第2层在内部，分别是：block_Impl_0 和 block_desc_0。）
    int e = 23;
    static int d = 4;
    static NSString *staticString = @"df";
    
    //第4层
    __block int c = 3;
    __block int c1 = 3;//虽然block没使用，但是底层还是会创建struct __Block_byref_c1_1
//     typedef __weak TestBlockClang *weakSelf = self;
    
//    __weak __typeof(TestBlockClang *)weakSelf = self;
//    __weak __typeof(&*self)weakSelf =self; 等同于

//    __weak TestBlockClang *weakSelf =self;
    
    //第5层（源文件搜索：Block_object_assign，
//    __block NSString *myString = @"不能用字面量，否则clang转换会失败";
    NSMutableString *str = [[NSMutableString alloc]initWithString:@"hello"];
    __block id obj = [[NSObject alloc]init];
    
    void (^blk)(void) = ^{
//        __strong TestBlockClang *strongSelf = weakSelf;
        
        a++;b++;c++;d++;a+=e;
        staticString = @"changed";
        obj = nil;
        [str appendString:@"world"];
        NSLog(@"1----------- a = %d,b = %d,c = %d,d = %d,str = %@",a,b,c,d,str);
    };
        
    NSLog(@"%@",[blk class]);
    a++;b++;c++;d++;
    str = [[NSMutableString alloc]initWithString:@"haha"];
    NSLog(@"2----------- a = %d,b = %d,c = %d,d = %d,str = %@",a,b,c,d,str);
    blk();
    
    void (^blk1)(void) = [blk copy];
    blk1();
}

#pragma mark - < 拷贝 >
//首先区分：集合与非集合。然后分：对象可变不可变。
- (void)testCopy {
    NSString *str = @"1";
    id str1 = [str copy];
    id str2 = [str mutableCopy];
    NSLog(@"%p %p %p",str,str1,str2);
    
    NSMutableString *mStr = [NSMutableString stringWithString:@"2"];
    id mStr1 = [mStr copy];
    id mStr2 = [mStr mutableCopy];
    NSLog(@"%p %p %p",mStr,mStr1,mStr2);
    
    
    //2 集合类型
    
    NSArray *arrI = @[@"",@""];
    id arrI1 = [arrI copy];
    id arrI2 = [arrI mutableCopy];
    NSLog(@"%p %p %p",arrI,arrI1,arrI2);
    
    NSMutableArray *arrM = [NSMutableArray arrayWithObjects:@"",@"", nil];
    id arrM1 = [arrM copy];
    id arrM2 = [arrM mutableCopy];
    NSLog(@"%p %p %p",arrM,arrM1,arrM2);

    //结论：凡是带mutable的，copy和mutable都是要创建新的内存空间。
    //疑问：mutable对象的copy为什么会开辟新空间。解释：类型变化导致需要开辟空间。
}

@end
