//
//  Test_Block.m
//  TestClang
//
//  Created by ming on 2021/4/3.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "Test_Block.h"
#import "TestCycle.h"

@interface Test_Block ()

@property (copy,nonatomic) NSString *name;
@property (strong, nonatomic) TestCycle *stu;

@end

@implementation Test_Block

- (instancetype)init {
    if(self = [super init]){
        [self test];
    }
    return self;
}

typedef void (^blk_t) (int count);

static int globalTmp = 2;
- (void)test {
    static int tmp = 3;
    int a = 5;
    blk_t blk = ^(int count) {
        tmp = 5;
        globalTmp = 0;
        printf("%d",a);
//        a = 2;
    };
//    blk_t blk1 =
//    void *blk1 = (__bridge void *)Block_copy(blk);//MRC下使用
    blk_t blk2 = [blk copy];
}

#pragma mark - < c数组 >
//block不支持C语言数组的截获
- (void)testBlockForCArray {
    const char text[] = "hello";
    const char *textPtr = "hello";
    
    void (^blk) (void) = ^ {
        printf("%c\n",textPtr[2]);
//        printf("%s\n",text);//打开注释就会编译错误。
    };
}

//c语言情况
void func(char a[10]) {
//    char b[10] = a;//无法将’C语言数组类型变量‘赋值给’C语言数组类型变量‘。
    char c[10] = {3};
    printf("%d",c[0]);
}

#pragma mark - < 循环引用 >
//用Instruments查看，待查看
- (void)testCycleRetain {
    TestCycle *student = [[TestCycle alloc]init];

    self.name = @"halfrost";
    self.stu = student;

    student.blockStudy = ^{
        NSLog(@"my name is = %@",self.name);
//        NSLog(@"my name is = %@",self);//或者这个
    };

    student.blockStudy();
}

@end
