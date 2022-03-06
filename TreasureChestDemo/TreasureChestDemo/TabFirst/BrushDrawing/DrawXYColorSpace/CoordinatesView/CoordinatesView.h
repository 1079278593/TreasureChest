//
//  CoordinatesView.h
//  TreasureChest
//
//  Created by imvt on 2022/1/14.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoordinatesView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

///xValue~x轴最大值(默认1)，step~有值刻度的距离(默认0.1)，accuracy~最小间隔(最小刻度，默认0.01)。
- (void)xAxisValue:(CGFloat)xValue step:(CGFloat)step accuracy:(CGFloat)accuracy;

///yValue~y轴最大值(默认1)，step~有值刻度的距离(默认0.1)，accuracy~最小间隔(最小刻度，默认0.01)。
- (void)yAxisValue:(CGFloat)yValue step:(CGFloat)step accuracy:(CGFloat)accuracy;

@end

NS_ASSUME_NONNULL_END
