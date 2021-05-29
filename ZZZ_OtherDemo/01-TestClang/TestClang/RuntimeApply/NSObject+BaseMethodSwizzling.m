//
//  NSObject+BaseMethodSwizzling.m
//  TestClang
//
//  Created by ming on 2021/5/3.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "NSObject+BaseMethodSwizzling.h"
#import <objc/runtime.h>

@implementation NSObject (BaseMethodSwizzling)

+ (void)base_classMethodSwizzlingWithOriginSEL:(SEL)originSEL targetSEL:(SEL)targetSEL {
    
    Class class = [self class];
    Method originMethod = class_getClassMethod(class, originSEL);
    Method targetMethod = class_getClassMethod(class, targetSEL);
    
    // 类方法需要获取元类
    Class metaClass = objc_getMetaClass(NSStringFromClass(class).UTF8String);
    NSLog(@"metaClass:%@", metaClass);
    
    // 尝试向元类中添加方法实现，如果添加成功，说明不存在原方法，如果失败则已经存在原方法
    BOOL isAddSuccess = class_addMethod(metaClass, originSEL, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    if (isAddSuccess) {
        // 替换原方法
        class_replaceMethod(metaClass, targetSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        // 直接交换方法实现
        method_exchangeImplementations(originMethod, targetMethod);
    }
    
}

+ (void)base_instanceMethodSwizzlingWithOriginSEL:(SEL)originSEL targetSEL:(SEL)targetSEL {
    
    Class class = [self class];
    Method originMethod = class_getInstanceMethod(class, originSEL);
    Method targetMethod = class_getInstanceMethod(class, targetSEL);
    
    // 尝试添加方法实现，如果添加成功，说明不存在原方法，如果失败则已经存在原方法
    BOOL isAddSuccess = class_addMethod(class, originSEL, method_getImplementation(targetMethod), method_getTypeEncoding(targetMethod));
    if (isAddSuccess) {
        // 替换原方法
        class_replaceMethod(class, targetSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        // 直接交换方法实现
        method_exchangeImplementations(originMethod, targetMethod);
    }
    
}

@end

