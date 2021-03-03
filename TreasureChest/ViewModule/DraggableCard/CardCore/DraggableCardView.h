//
//  DraggableCardView.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DraggableConfig.h"

@interface DraggableCardView : UIView

@property (nonatomic) CGAffineTransform originalTransform;

- (void)cc_layoutSubviews;

@end
