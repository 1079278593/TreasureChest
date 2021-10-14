//
//  ResidentScrollView.h
//  TreasureChest
//
//  Created by ming on 2019/12/7.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResidentScrollView : UIScrollView

- (void)showResident:(UITableView *)contentView headerView:(UIView *)headerView residentHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
