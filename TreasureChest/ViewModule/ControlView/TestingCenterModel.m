//
//  TestingCenterModel.m
//  amonitor
//
//  Created by imvt on 2021/10/14.
//  Copyright © 2021 Imagine Vision. All rights reserved.
//

#import "TestingCenterModel.h"

@implementation TestingCenterCellModel

@end

@implementation TestingCenterModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"datas" : NSStringFromClass([TestingCenterCellModel class]),
    };//前边，是属性数组的名字，后边就是类名
}

+ (NSArray <TestingCenterModel *> *)generateDatas {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"TestingDatas" ofType:@"plist"];
    NSArray *arr = [TestingCenterModel mj_objectArrayWithFile:path];
    return arr;
}

@end
