//
//  CollapsibleViewModel.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollapsibleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CollapsibleViewModel : NSObject

//@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *datas;

///完整的整个数据结构
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *rootItems;
///当前需要展示的数据
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *currentItems;
///上一次展示的数据
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *lastedItems;
///已经选中的选项, 用于回调
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *selectedItems;

- (void)resetVisibleItems;
- (void)assemblyVisibleItems:(NSArray<CollapsibleModel *> *)menuItems index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
