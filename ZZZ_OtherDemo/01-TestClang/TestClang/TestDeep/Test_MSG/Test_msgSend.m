//
//  Test_msgSend.m
//  TreasureChest
//
//  Created by ming on 2020/5/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "Test_msgSend.h"
#import "objc/runtime.h"
#import "Test_ForwardingTarget.h"

@implementation Test_msgSend

- (void)testStart {
    
    [self printMethodList];
    
    [self testInvocation];
//    [self testSetValue];
    
    //经过前后打印发现，方法被添加进methodList中了。
    [self printMethodList];
}

//1.调用没有实现的方法
- (void)testInvocation {
    [self performSelector:@selector(testBeInvoke:) withObject:@""];
}

//2.给不存在的key赋值。
//kvc方式可以操作：readonly的属性、@protected的成员变量。将accessInstanceVariablesDirectly属性赋值为NO，防止外界访问类的成员变量。
- (void)testSetValue {
    /*
     1.首先触发4次resolveInstanceMethod：
     (SEL)sel值分别是：setKey:、_setKey:、setIsKey:、setPrimitiveKey:
     
     2.然后触发2次：resolveClassMethod：
     (SEL)sel值：dynamicContextEvaluation:patternString:
     (SEL)sel值：descriptionWithLocale:
    */
    [self setValue:@"1" forKey:@"ad"];
}

#pragma mark - < 1.动态添加 >
///类方法的添加
+ (BOOL)resolveClassMethod:(SEL)sel {
    NSLog(@"阶段1，resolveClassMethod：%@",NSStringFromSelector(sel));
    NSLog(@"阶段1，resolveClassMethod：%@",NSStringFromSelector(_cmd));
    return !NO;
}
///实例方法的添加
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"阶段1，resolveInstanceMethod：%@",NSStringFromSelector(sel));
    NSLog(@"阶段1，resolveInstanceMethod：%@",NSStringFromSelector(_cmd));//_cmd感觉像本方法的名称
    
    /**
     返回值类型：v         —— 代表 void
     第一个参数类型：@      —— 代表对象
     第二个参数类型：:      —— 代表 SEL
     第三个参数类型：@      —— 代表对象
     */
//    if(sel == @selector(testBeInvoke:)){
//        class_addMethod([self class], sel, (IMP)dynamicMethodIMP, "v@:");
//        return YES;//如果已经添加了实现，返回什么不重要了
//    }

    return  [super resolveInstanceMethod:sel];
}

void dynamicMethodIMP(id self, SEL _cmd) {
    NSLog(@"方法动态添加实现，原方法名称： %@",NSStringFromSelector(_cmd));
}

#pragma mark - < 2. 转发，每次都要走一遍 >
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"阶段2，%@",NSStringFromSelector(aSelector));
    NSLog(@"阶段2，%@",NSStringFromSelector(_cmd));
    
    if([NSStringFromSelector(aSelector) isEqualToString:@"testBeInvoke:"]){
        return [[Test_ForwardingTarget alloc]init];
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - < 3. 返回方法签名，每次调用都要走一遍 >
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"阶段3，%@",NSStringFromSelector(aSelector));
    NSLog(@"阶段3，%@",NSStringFromSelector(_cmd));
    
    NSString *SelStr = NSStringFromSelector(aSelector);
    if([SelStr isEqualToString:@"testBeInvoke:"]){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}
//处理返回的方法签名
-(void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"阶段3，后续处理：%@",NSStringFromSelector(_cmd));
    NSLog(@"阶段3，后续处理：%@",anInvocation);
    
    //方法1：改变消息接受者对象
//    [anInvocation invokeWithTarget:[[Test_ForwardingTarget alloc]init]];
    
    //方法2：改变消息的SEL
    anInvocation.selector = @selector(replaceMethod:);
    [anInvocation invokeWithTarget:self];
}
//用新的对象，新的方法替换的方法
- (void)replaceMethod:(NSString *)para {
    [self printMethodList];
}

/*
 *另外一种方式
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        B *bObject = [[B alloc] init]; // 假设B中有实例方法aSelector
        signature = [bObject methodSignatureForSelector:aSelector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    B *bObject = [[B alloc] init];
    [anInvocation invokeWithTarget:bObject];
}
*/

#pragma mark - < 触发崩溃 >
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
}

#pragma mark - < 打印 >
// 打印成员变量列表
- (void)printIvarList {
    unsigned int count;
    
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"ivar(%d) : %@", i, [NSString stringWithUTF8String:ivarName]);
    }
    
    free(ivarList);
}

// 打印属性列表
- (void)printPropertyList {
    unsigned int count;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"propertyName(%d) : %@", i, [NSString stringWithUTF8String:propertyName]);
    }
    
    free(propertyList);
}

// 打印方法列表
- (void)printMethodList {
    unsigned int count;
    
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method(%d) : %@", i, NSStringFromSelector(method_getName(method)));
    }
    
    free(methodList);
}

@end
