//
//  TestBlockClang.h
//  TestClang
//
//  Created by ming on 2021/4/6.
//  Copyright © 2021 雏虎科技. All rights reserved.
//  用：「 clang -rewrite-objc 文件名.m 」命令将 oc 代码重写成 c++:
//  比如：clang -rewrite-objc TestBlockClang.m
/**
 1.编译的命令：xcrun clang -c TestBlockClang.m
 2.查看符号：符号表会规定它们的符号，你可以使用 nm 工具查看
 命令：xcrun nm -nm TestBlockClang.o
 */
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestBlockClang : NSObject

@property(nonatomic, copy)NSMutableArray *dsafs;

- (void)test;

@end

NS_ASSUME_NONNULL_END
