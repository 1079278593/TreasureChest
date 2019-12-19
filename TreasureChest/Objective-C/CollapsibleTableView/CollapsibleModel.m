//
//  CollapsibleModel.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "CollapsibleModel.h"

@implementation CollapsibleModel

/**
 指定subs数组中存放LTMenuItem类型对象
 */
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"subs" : [CollapsibleModel class]
            };//前边，是属性数组的名字，后边就是类名
}

/**
 判断是否能够展开, 当subs中有数据时才能展开
 */
- (BOOL)isCanUnfold
{
    return self.subs.count > 0;
}

@end
