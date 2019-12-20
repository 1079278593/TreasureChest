//
//  TabScrollView.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabTitleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TabScrollView : UIView

@property(strong, nonatomic)TabTitleScrollView *titleScrollView;
@property(strong, nonatomic)UIScrollView *contentScrollView;

- (instancetype)initWithFrame:(CGRect)frame contents:(NSArray *)views titles:(NSArray *)titles;


@end

NS_ASSUME_NONNULL_END
