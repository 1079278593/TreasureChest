//
//  ControllerTableView.h
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TabType) {
    TabType_first = 0,
    TabType_second,
    TabType_third,
};

@interface ControllerTableView : UIView

- (void)showWithTabType:(TabType)type;

@end

NS_ASSUME_NONNULL_END
