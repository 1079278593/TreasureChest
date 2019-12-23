//
//  XMLabel.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    VerticalAlignmentTop = 0,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom
} VerticalAlignment;

NS_ASSUME_NONNULL_BEGIN

@interface XMLabel : UILabel
@property(assign, nonatomic)VerticalAlignment verticalAlignment;
@end

NS_ASSUME_NONNULL_END
