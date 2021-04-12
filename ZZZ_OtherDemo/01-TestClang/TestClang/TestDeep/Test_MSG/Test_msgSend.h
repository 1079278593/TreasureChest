//
//  Test_msgSend.h
//  TreasureChest
//
//  Created by ming on 2020/5/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Test_msgSend : NSObject

@property(nonatomic, strong)NSString *testProperty;//看看打印是否有setTestProperty:方法

- (void)testStart;

// 打印成员变量列表
- (void)printIvarList;
// 打印属性列表
- (void)printPropertyList;
// 打印方法列表
- (void)printMethodList;

@end

NS_ASSUME_NONNULL_END
