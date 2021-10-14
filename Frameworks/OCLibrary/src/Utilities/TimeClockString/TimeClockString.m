//
//  TimeClockString.m
//  iPhoneApp
//
//  Created by 小明 on 2017/10/27.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "TimeClockString.h"

@implementation TimeClockString

+ (NSString *)second2Date:(NSInteger)seconds {
    NSString *hour = [self timeFormat:(int)seconds/(60*60)];
    NSString *minutes = [self timeFormat:(int)seconds/60];
    NSString *second = [self timeFormat:(int)seconds%60];
    
    NSString *newTime;
    if (seconds >= 60*60) {
        newTime = [NSString stringWithFormat:@"%@:%@:%@",hour,minutes,second];
    }else {
        newTime = [NSString stringWithFormat:@"%@:%@",minutes,second];
    }
    
    return newTime;
}

+ (NSString *)timeFormat:(NSInteger)number{
    
    if (number<10) {
        return [NSString stringWithFormat:@"0%ld",(long)number];
    }else{
        return [NSString stringWithFormat:@"%ld",(long)number];
    }
    
}

@end
