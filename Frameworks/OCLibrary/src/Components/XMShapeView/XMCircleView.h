//
//  XMCircleView.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "BaseShapeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMCircleView : BaseShapeView

///弧度的值范围：0~1
@property(assign, nonatomic)CGFloat arcAngle;

@end

NS_ASSUME_NONNULL_END
