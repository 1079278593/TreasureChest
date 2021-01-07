//
//  CollapsibleViewCell.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapsibleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CollapsibleViewCell : UITableViewCell

/** 菜单项模型 */
@property (nonatomic, strong) CollapsibleModel *menuItem;

@end

NS_ASSUME_NONNULL_END
