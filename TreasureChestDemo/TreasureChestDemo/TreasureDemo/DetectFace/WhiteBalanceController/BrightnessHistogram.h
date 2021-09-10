//
//  BrightnessHistogram.h
//  TreasureChest
//
//  Created by imvt on 2021/8/10.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAMChart.h"

NS_ASSUME_NONNULL_BEGIN

@interface BrightnessHistogram : NSObject

- (CAMLineChart*)getHistogramChartViewWithFrame:(CGRect)frame;
- (NSMutableArray *)brightnessFromPixelBuffer:(CVImageBufferRef)imageBuffer;
- (NSMutableArray *)brightnessWithVImageFromPixelBuffer:(CVImageBufferRef)imageBuffer;


- (NSMutableArray *)getTestDatas;

@end

NS_ASSUME_NONNULL_END
