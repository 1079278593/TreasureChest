//
//  TestDeep.m
//  TestClang
//
//  Created by ming on 2021/4/10.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "TestDeep.h"
#import "objc/runtime.h"

#import "Test_msgSend.h"
#import "Test_ForwardingTarget.h"
#import "TestGCD.h"
#import "TestClang.h"
#import "Test_ARC.h"
#import "Test_MRC.h"
#import "Test_ISA.h"
#import "TestKVO.h"

//AOP
#import "AspectProxy.h"
#import "AuditingInvoker.h"
#import "Student.h"

@interface TestDeep ()

@property(nonatomic, strong)Test_msgSend *test;
@property(nonatomic, strong)TestGCD *testGCD;

@end

@implementation TestDeep

- (instancetype)init {
    if(self = [super init]){

    }
    return self;
}

#pragma mark - < public >
- (void)testDeepMethod1 {
    int type = 3;
    switch (type) {
        case 0:
        {
            [self testMsg];
        }
            break;
        case 1:
        {
            [self testThread];
        }
            break;
        case 2:
        {
            NSString *originString = @"originString";
            [self testCopy:originString];
        }
            break;
        case 3:
        {
            [self testAOP];
        }
            break;
        case 4:
        {
            [self testReferenceCount];//test arc/mrc
        }
            break;
        case 5:
        {
//            Test_ISA *testISA = [[Test_ISA alloc]init];
            [TestKVO testNoImplementation];
        }
            break;
            
        default:
            break;
    }
}

- (void)testDeepMethod2 {
    [self.testGCD testPort];
}

#pragma mark - < test methods >
#pragma mark < 1.test msg >
- (void)testMsg {
    self.test = [[Test_msgSend alloc]init];
    
    [self.test printMethodList];
    [self.test printIvarList];
    [self.test printPropertyList];
    [self.test testStart];//测试class_addMethod()添加后，是否存入到了methodList中了。
    
//    [self.test testStart];
}

#pragma mark < 2.test thread >
- (void)testThread {
    self.testGCD = [[TestGCD alloc]init];
}

#pragma mark < 3.test copy property >
- (void)testCopy:(NSString *)string {
    
    NSString *originString = @"string";
    NSMutableString *originString1 = [NSMutableString stringWithString:@"string"];
    NSMutableString *originString2 = [NSMutableString stringWithString:@"string"];
    
    TestClang *testCopy = [[TestClang alloc]init];
    
    testCopy.testCopy = originString;
    testCopy.testCopy = originString1;
    testCopy.testCopy = originString2;
    
    testCopy.testMutableCopy = originString1;
    
    testCopy.testStrong = originString;
    testCopy.testStrong = originString1;
}

#pragma mark < 4. test AOP >
- (void)testAOP {
    id student = [[Student alloc] init];

    // 设置代理中注册的选择器数组
    NSValue *selValue1 = [NSValue valueWithPointer:@selector(study:andRead:)];
    NSArray *selValues = @[selValue1];
    
    // 创建AuditingInvoker
    AuditingInvoker *invoker = [[AuditingInvoker alloc] init];
    
    // 创建Student对象的代理studentProxy（id类型可以调用:本类import的所有类的.h方法）
    id studentProxy = [[AspectProxy alloc] initWithObject:student selectors:selValues andInvoker:invoker];
    
    // 使用指定的选择器向该代理发送消息---例子1（这个类显然没有这个方法的实现，必然走消息转发）
    [studentProxy study:@"Computer" andRead:@"Algorithm"];
    
    // 使用还未注册到代理中的其他选择器，向这个代理发送消息！---例子2
    [studentProxy study:@"mathematics" :@"higher mathematics"];
    
    // 为这个代理注册一个选择器并再次向其发送消息---例子3
    [studentProxy registerSelector:@selector(study::)];
    [studentProxy study:@"mathematics" :@"higher mathematics"];

    
    //改造：就是这里一行代码，把self传入即可。内部处理各种横切功能。
    /**
     这个例子就实现了一个简单的AOP(Aspect Oriented Programming)面向切面编程。我们把一切功能"切"出去，与其他部分分开，这样可以提高程序的模块化程度。
     AOP能解耦也能动态组装，可以通过预编译方式和运行期动态代理实现在不修改源代码的情况下给程序动态统一添加功能。比如上面的例子三，我们通过把方法注册到动态代理类中，于是就实现了该类也能处理方法的功能。
     */
    
}

- (void)testReferenceCount {
    [[Test_ARC alloc]init];
    [[Test_MRC alloc]init];
}
@end
