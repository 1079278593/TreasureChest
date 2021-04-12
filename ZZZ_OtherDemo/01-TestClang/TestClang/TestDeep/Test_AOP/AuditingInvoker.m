//
//  AuditingInvoker.m
//  TestClang
//
//  Created by ming on 2021/3/30.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "AuditingInvoker.h"

@implementation AuditingInvoker

- (void)preInvoke:(NSInvocation *)inv withTarget:(id)target{
    NSLog(@"before sending message with selector %@ to %@ object", NSStringFromSelector([inv selector]),[target class]);
}

- (void)postInvoke:(NSInvocation *)inv withTarget:(id)target{
    NSLog(@"after sending message with selector %@ to %@ object", NSStringFromSelector([inv selector]),[target class]);
}

@end
