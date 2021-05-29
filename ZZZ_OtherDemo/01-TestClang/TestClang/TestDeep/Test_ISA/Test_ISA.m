//
//  Test_ISA.m
//  TestClang
//
//  Created by ming on 2021/4/5.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "Test_ISA.h"
#import "objc/runtime.h"
#import "Student.h"

@interface Test_ISA ()

@end

@implementation Test_ISA

- (instancetype)init {
    if(self = [super init]){
        [self test];
        [self test1];
        //重复两次用Student的实例，获取的class的地址都是一样的，说明每个对象都有一个类，这个类是固定地址的‘类对象’。
    }
    return self;
}

/*
 object_getClass在文件：objc-class.mm。返回isa
 元类的isa指向基元类，基元类指向自己，基元类的父类指向NSObject
 
 objc_getClass在文件：objc-runtime.mm。返回只是返回了Class，而非成员isa的Class
*/
- (void)test {
    Student *sonObject = [Student new];
    Class currentClass = [sonObject class];
    const char *className = object_getClassName(currentClass);
    
    for (int i=0; i<4; i++) {
        NSLog(@"class:%p-----className:%s-------superClass:%@\n",currentClass,className,[currentClass superclass]);
        currentClass = object_getClass(currentClass);
        className = object_getClassName(currentClass);
    }
    NSLog(@"");
}

- (void)test1 {
    Student *sonObject = [[Student alloc]init];
    Class currentClass = [sonObject class];
    const char *className = object_getClassName(currentClass);

    for (int i=0; i<4; i++) {
        NSLog(@"class:%p-----className:%s-------superClass:%@\n",currentClass,className,[currentClass superclass]);
        currentClass = objc_getClass([NSStringFromClass(currentClass) UTF8String]);
        className = object_getClassName(currentClass);
    }
}


@end
