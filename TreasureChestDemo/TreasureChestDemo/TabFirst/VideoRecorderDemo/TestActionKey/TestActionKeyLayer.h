//
//  TestActionKeyLayer.h
//  TreasureChest
//
//  Created by xiao ming on 2020/4/17.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestActionKeyLayer : CAShapeLayer

//1~100
@property (assign, nonatomic) float arcLenght;
- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
