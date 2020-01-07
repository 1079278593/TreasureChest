//
//  BaseShapeView.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseShapeView : UIView

@property(assign, nonatomic)CGFloat lineWidth;
@property(strong, nonatomic)UIColor *strokeColor;

@end

NS_ASSUME_NONNULL_END
