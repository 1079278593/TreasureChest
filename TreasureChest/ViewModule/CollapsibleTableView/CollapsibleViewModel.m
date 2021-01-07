//
//  CollapsibleViewModel.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "CollapsibleViewModel.h"
#import "MJExtension.h"

@interface CollapsibleViewModel()

@end

@implementation CollapsibleViewModel

- (instancetype)init {
    if(self == [super init]){
        [self requestPlistData];
    }
    return self;
}

//测试数据
- (void)requestPlistData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TestData" ofType:@"plist"];
    NSArray *date = [NSArray arrayWithContentsOfFile:filePath];
    self.rootItems = [CollapsibleModel mj_objectArrayWithKeyValuesArray:date];
}

#pragma mark - < 添加可以展示的选项 >
- (void)resetVisibleItems {
    self.lastedItems = [NSMutableArray arrayWithArray:self.currentItems];
    
    // 清空当前所有展示项
    [self.currentItems removeAllObjects];
    
    // 重新添加需要展示项, 并设置层级, root层级为0
    [self assemblyVisibleItems:self.rootItems index:0];
}

/**
 将需要展示的选项添加到currentItems中, 此方法使用递归添加所有需要展示的层级到currentItems中

 @param menuItems 需要添加到currentItems中的数据
 @param index 层级, 即当前添加的数据属于第几层
 */
- (void)assemblyVisibleItems:(NSArray<CollapsibleModel *> *)menuItems index:(NSInteger)index {
    for (int i = 0; i < menuItems.count; i++) {
        CollapsibleModel *item = menuItems[i];
        // 设置当前层级
        item.index = index;
        // 将选项添加到数组中
        [self.currentItems addObject:item];
        // 判断该选项的是否能展开, 并且已经需要展开
        if (item.isCanUnfold && item.isUnfold) {
            // 当需要展开子集的时候, 添加子集到数组, 并设置子集层级
            [self assemblyVisibleItems:item.subs index:index + 1];
        }
    }
}

#pragma mark - getter and setter
- (NSMutableArray<CollapsibleModel *> *)currentItems {
    if (!_currentItems) {
        _currentItems = [[NSMutableArray alloc] init];
    }
    return _currentItems;
}

- (NSMutableArray<CollapsibleModel *> *)selectedItems {
    if (!_selectedItems) {
        _selectedItems = [[NSMutableArray alloc] init];
    }
    return _selectedItems;
}

@end
