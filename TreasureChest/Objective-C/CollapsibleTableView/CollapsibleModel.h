//
//  CollapsibleModel.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollapsibleModel : NSObject

@property (nonatomic, strong) NSArray<CollapsibleModel *> *subs;

@property(copy, nonatomic)NSString *contactUser;
@property(copy, nonatomic)NSString *mchId;
@property(copy, nonatomic)NSString *mchName;
@property(copy, nonatomic)NSString *posId;
@property(copy, nonatomic)NSString *posName;
@property(assign, nonatomic)NSInteger mchType;

#pragma mark - < 辅助属性 >
/** 名字 */
@property (nonatomic, strong) NSString *name;

/** 是否选中 */
@property (nonatomic, assign) BOOL isSelected;

/** 是否展开 */
@property (nonatomic, assign) BOOL isUnfold;

/** 是否能展开 */
@property (nonatomic, assign) BOOL isCanUnfold;

/** 当前层级 */
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
