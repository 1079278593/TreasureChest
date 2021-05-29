//
//  NSArray+Boundary.m
//  TestClang
//
//  Created by ming on 2021/5/3.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "NSArray+Boundary.h"
#import "NSObject+BaseMethodSwizzling.h"
#import <objc/runtime.h>

@implementation NSArray (Boundary)

/**
 hook造成数组越界的方法（NSArray的objectAtIndex:和objectAtIndexedSubscript:方法）。
 objectAtIndex:是我们需要知道和使用的方法，
 objectAtIndexedSubscript:是提供对obj-c下标支持的方法，也可以说是编译器使用的方法。
 思考：是否有这个必要？
 nsarray在项目中大量用到，系统代码，自己的代码，这个待商榷。
 观察：每次简单的点击一个按钮就有大量的替换发生，增加arrayMutable的替换，会有更多的’替换调用‘。
 */

+ (void)load {
    return;
    //使用单例模式
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 获取四种隐藏的实现类(还有一种：__NSPlaceholderArray）
        Class arrayI = objc_getClass("__NSArrayI");
//        Class arrayEmpty = objc_getClass("__NSArray0");
//        Class arraySingle = objc_getClass("__NSSingleObjectArrayI");
//        Class arrayMutable = objc_getClass("__NSArrayM");  // 可变数组
        
        // 每种实现类都需要hook相关方法
        [arrayI base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndex:) targetSEL:@selector(targetArrayI_objectAtIndex:)];
//        [arrayI base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndexedSubscript:) targetSEL:@selector(targetArrayI_objectAtIndexedSubscript:)];
        
//        [arrayEmpty base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndex:) targetSEL:@selector(targetArrayEmpty_objectAtIndex:)];
//        [arrayEmpty base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndexedSubscript:) targetSEL:@selector(targetArrayEmpty_objectAtIndexedSubscript:)];
        
//        [arraySingle base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndex:) targetSEL:@selector(targetArraySingle_objectAtIndex:)];
//        [arraySingle base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndexedSubscript:) targetSEL:@selector(targetArraySingle_objectAtIndexedSubscript:)];
        
//        [arrayMutable base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndex:) targetSEL:@selector(targetArrayMutable_objectAtIndex:)];
//        [arrayMutable base_instanceMethodSwizzlingWithOriginSEL:@selector(objectAtIndexedSubscript:) targetSEL:@selector(targetArrayMutable_objectAtIndexedSubscript:)];

    });
}

#pragma mark - Array
- (id)targetArrayI_objectAtIndex:(NSUInteger)index {
    NSLog(@"arrayI :，index=%@，count=%@", @(index), @(self.count));
//    NSAssert((index < self.count), ([NSString stringWithFormat:]));
    if (index < self.count) {
        return [self targetArrayI_objectAtIndex:index];
    }
    return nil;
}
- (id)targetArrayI_objectAtIndexedSubscript:(NSUInteger)index {
    NSLog(@"arrayI subscript:，index=%@，count=%@", @(index), @(self.count));
//    NSAssert((index < self.count), ([NSString stringWithFormat:]));
    if (index < self.count) {
        return [self targetArrayI_objectAtIndexedSubscript:index];
    }
    return nil;
}
 
#pragma mark - Empty array
- (id)targetArrayEmpty_objectAtIndex:(NSUInteger)index {
    // 空数组永远返回nil
    NSLog(@"arrayI Empty_index：%lu",index);
    return nil;
}

- (id)targetArrayEmpty_objectAtIndexedSubscript:(NSUInteger)index {
    NSLog(@"arrayI Empty_subscript：%lu",index);
    return nil;
}
 
#pragma mark - Single array
- (id)targetArraySingle_objectAtIndex:(NSUInteger)index {
    NSLog(@"Single array:，index=%@，count=%@", @(index), @(self.count));
//    NSAssert((index < self.count), ([NSString stringWithFormat:]));
    if (index < self.count) {
        return [self targetArraySingle_objectAtIndex:index];
    }
    return nil;
}
- (id)targetArraySingle_objectAtIndexedSubscript:(NSUInteger)index {
    NSLog(@"Single array subscript:，index=%@，count=%@", @(index), @(self.count));
//    NSAssert((index < self.count), ([NSString stringWithFormat:]));
    if (index < self.count) {
        return [self targetArraySingle_objectAtIndexedSubscript:index];
    }
    return nil;
}
 
#pragma mark - Mutable array
- (id)targetArrayMutable_objectAtIndex:(NSUInteger)index {
    NSLog(@"Mutable array:，index=%@，count=%@", @(index), @(self.count));
//    NSAssert((index < self.count), ([NSString stringWithFormat:]));
    if (index < self.count) {
        return [self targetArrayMutable_objectAtIndex:index];
    }
    return nil;
}

- (id)targetArrayMutable_objectAtIndexedSubscript:(NSUInteger)index {
    NSLog(@"Mutable array subscript:，index=%@，count=%@", @(index), @(self.count));
//    NSAssert((index < self.count), ([NSString stringWithFormat:));
    if (index < self.count) {
        return [self targetArrayMutable_objectAtIndexedSubscript:index];
    }
    return nil;
}

@end
