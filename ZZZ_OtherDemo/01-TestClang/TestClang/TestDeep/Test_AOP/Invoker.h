//
//  Invoker.h
//  TestClang
//
//  Created by ming on 2021/3/30.
//  Copyright © 2021 雏虎科技. All rights reserved.
//  协议

#import <Foundation/Foundation.h>

@protocol Invoker <NSObject>

@required
// 在调用对象中的方法前执行对功能的横切
- (void)preInvoke:(NSInvocation *)inv withTarget:(id)target;
@optional
// 在调用对象中的方法后执行对功能的横切
- (void)postInvoke:(NSInvocation *)inv withTarget:(id)target;

@end
