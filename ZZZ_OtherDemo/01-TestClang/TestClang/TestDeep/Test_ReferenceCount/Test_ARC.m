//
//  Test_ARC.m
//  TestClang
//
//  Created by ming on 2021/4/1.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "Test_ARC.h"

@interface Test_ARC ()

@end

@implementation Test_ARC

- (instancetype)init {
    if(self = [super init]){
        [self test];
        [self testPointer];
        [self testReferenceCount];
    }
    return self;
}

#pragma mark - < 计数器 >
- (void)testReferenceCount {
    
}

#pragma mark - < 修饰符 >
- (void)test {
    id __strong obj;
    id __autoreleasing obj1;
    id __weak obj2 = [[NSObject alloc]init];
    NSObject __autoreleasing *obj20 = [[NSObject alloc]init];
    NSObject __autoreleasing *obj21 = obj20;
    id __unsafe_unretained obj3 = [[NSObject alloc]init];
    NSLog(@"1.0 :%@",obj);
    NSLog(@"1.1 :%@",obj1);
    NSLog(@"1.2 :%@ obj20:%p,obj21:%@",obj2,&obj20,obj21);
//    NSLog(@"1.3 :%@",obj3);
    {
        id __strong obj0 = [[NSObject alloc]init];
//        CFBridgingRetain(obj0);
        obj2 = obj0;
        obj3 = obj0;
        NSLog(@"3 :%@",obj2);
        NSLog(@"4 :%@",obj3);
    }
    NSLog(@"5 :%@",obj2);
//    NSLog(@"6 :%@",obj3);
}

#pragma mark - < 查看指针打印 >
//https://www.jianshu.com/p/00c2c189f403?from=singlemessage
- (void)testPointer {
//    NSString *str0 = @"XTShow";
//    NSLog(@"0------自身内存地址：%p--对象内存地址：%p",&str0,str0);
    NSString *str1 = @"XTShowXTShowXTShow";//使长度大于9位，避免NSTaggedPointerString的影响
    NSLog(@"1------自身内存地址：%p--对象内存地址：%p",&str1,str1);
    [self testPointer:str1 str2:&str1];

}

- (void)testPointer:(NSString *)str1 str2:(NSString **)str2 {
    
    NSLog(@"");
    NSLog(@"3------自身内存地址：%p--对象内存地址：%p",&str1,str1);
    NSLog(@"");
    
    //二重指针
    NSLog(@"4~二重指针~自身内存地址：%p--对象内存地址：%p",&str2,str2);
    //一重指针
    NSLog(@"5~一重指针~自身内存地址：%p--对象内存地址：%p",&(*str2),*str2);
}
@end
