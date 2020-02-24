//
//  XMDashLineView.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "BaseShapeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMDashLineView : BaseShapeView

/**
 规律就是：绘制、不绘制、绘制、不绘制，如此不断循环。
 phase = 0
 1. {10,5}  绘制10，跳过5
 2. {10,5,3} 绘制10，跳过5，绘制3，跳过10。
 
 phase = n  （起始不绘制的长度:n）
 1. lengths = {10,5}    phase = 4    结果：绘制10-4，跳过5，绘制10....
 2. lengths = {10,5}    phase = 8    结果：绘制10-8，跳过5，绘制10....
 
 */
@property(nonatomic, strong)NSArray <NSNumber *>*lengthArray;

@end

NS_ASSUME_NONNULL_END
