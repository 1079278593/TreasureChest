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

@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *datas;

@end

NS_ASSUME_NONNULL_END
