//
//  BrightnessHistogram.m
//  TreasureChest
//
//  Created by imvt on 2021/8/10.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "BrightnessHistogram.h"

#define KColorValue 255

@implementation BrightnessHistogram

#pragma mark - < public >
+ (CAMLineChart*)getHistogramChartViewWithFrame:(CGRect)frame {
    
    CAMChartProfile *profile = [[CAMChartProfileManager shareInstance].defaultProfile mutableCopy];
    profile.xyAxis.showYGrid = YES;
    profile.xyAxis.showXGrid = NO;
    profile.lineChart.lineStyle = CAMChartLineStyleCurve;       //曲线样式

    CAMLineChart *chart = [[CAMLineChart alloc] initWithFrame:frame];
    chart.backgroundColor = [UIColor clearColor];
    
    chart.chartProfile = profile;
    chart.xUnit = @"亮度";
    chart.yUnit = @"数量";
//    chart.xLabels = [self getlabels];
//    chart.yLabels = @[@"0", @"60", @"120"];
    
    NSArray *data00 = [self getDatas];
    [chart addChartData:data00];
    
    NSArray *data01 = [self getDatas];
    [chart addChartData:data01];
    
    [chart drawChartWithAnimationDisplay:NO];
    
    return chart;
}

- (NSMutableArray *)getlabels {
    NSMutableArray *labels =[NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<KColorValue; i++) {
        [labels addObject:[NSString stringWithFormat:@""]];
    }
    return labels;
}

+ (NSMutableArray *)getDatas {
    NSMutableArray *datas =[NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<55; i++) {
        int index = arc4random() % 500 + 500;
        [datas addObject:@(index)];
    }
    
    for (int i = 0; i<80; i++) {
        int index = arc4random() % 200 + 200;
        [datas addObject:@(index)];
    }
    
    for (int i = 0; i<60; i++) {
        int index = arc4random() % 100 + 100;
        [datas addObject:@(index)];
    }
    
    for (int i = 0; i<60; i++) {
        int index = arc4random() % 300 + 300;
        [datas addObject:@(index)];
    }
    
    return datas;
}

@end
