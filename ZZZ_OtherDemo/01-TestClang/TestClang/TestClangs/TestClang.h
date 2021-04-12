//
//  TestClang.h
//  TreasureChest
//
//  Created by ming on 2020/5/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//  用 clang -rewrite-objc 命令将 oc 代码重写成 c++:

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestClang : NSObject

@property(nonatomic, copy)NSString *testCopy;
@property(nonatomic, copy)NSMutableString *testMutableCopy;
@property(nonatomic, strong)NSString *testStrong;

@end

NS_ASSUME_NONNULL_END
