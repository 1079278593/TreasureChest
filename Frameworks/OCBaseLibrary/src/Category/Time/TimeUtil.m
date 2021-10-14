//
//  TimeUtil.m
//  TreasureChest
//
//  Created by xiao ming on 2019/11/13.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil

+(NSString *)generateAll : (NSString *)timestamp{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss.SSS"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

//注意时间戳是秒的还是毫秒的
+(NSString *)generateDate:(NSString *)timestamp format:(NSString *)formatStr{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formatStr];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+(NSString *)generateDate_CH : (NSString *)timestamp{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+(NSString *)generateDate_EN:(NSString *)timestamp{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+(NSString *)generateTime : (NSString *)timestamp{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    NSString* timeString = [formatter stringFromDate:date];
    return timeString;
}

+(NSString *)getTomorrowDate{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval=[dat timeIntervalSince1970];
    timeInterval += 3600 * 24;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSString *)getTodayDate{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval=[dat timeIntervalSince1970];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+(NSString *)getLastDate{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval=[dat timeIntervalSince1970];
    timeInterval -= 3600 * 24;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}



+ (NSString *)getLastDates:(int)day format:(NSString *)format{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval=[dat timeIntervalSince1970];
    timeInterval -=  3600 * 24  * (day-1);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString* dateStr = [formatter stringFromDate:date];
    return dateStr;
}


+(NSString *)formateTime : (NSString *)timestamp{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval createTime = [timestamp longLongValue]/1000;
    NSTimeInterval time = currentTime - createTime;
    long sec = time/60;
    if(sec == 0){
        return @"刚刚";
    }
    
    if (sec<60) {
        return [NSString stringWithFormat:@"%ld分钟前",sec];
    }
    
    // 秒转小时
    NSInteger hours = time/3600;
    if (hours<24) {
        return [NSString stringWithFormat:@"%ld小时前",hours];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 30) {
        return [NSString stringWithFormat:@"%ld天前",days];
    }
    //秒转月
    NSInteger months = time/3600/24/30;
    if (months < 12) {
        return [NSString stringWithFormat:@"%ld月前",months];
    }
    //秒转年
    NSInteger years = time/3600/24/30/12;
    return [NSString stringWithFormat:@"%ld年前",years];
}

//引力区
+(NSString *)formateTimeYinLiQu:(NSString *)timestamp {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval createTime = [timestamp longLongValue]/1000;
    NSTimeInterval time = currentTime - createTime;
    
    if ([self isThisYear:timestamp]) {
        // 秒转小时
        NSInteger hours = time/3600;
        if (hours<24) {
            long sec = time/60;
            if(sec == 0){
                return @"刚刚";
            }
            if ([self isYesterday:timestamp]) {
                return @"昨天";
            }
            if (sec<60) {
                return [NSString stringWithFormat:@"%ld分钟前",sec];
            }
            return [NSString stringWithFormat:@"%ld小时前",hours];
        }else {
            return [self generateDate:timestamp format:@"MM月dd日"];
        }
    }
    return [self generateDate:timestamp format:@"yyyy年MM月dd日"];
}

+(NSString *)formateAge:(long)timestamp {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval createTime = timestamp/1000;
    NSTimeInterval time = currentTime - createTime;
    NSInteger years = time/3600/24/30/12;
    return [NSString stringWithFormat:@"%ld",years];
}

+(NSString *)getCurrentTimeStamp{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%f", a];
}

+(NSString *)getTimeStampWithDays:(int)days{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    a += 3600 * 24 * 1000 * days;
    return [NSString stringWithFormat:@"%f", a];
}


+(NSString *)getCurrentWeek:(NSDate *)date{
    long now = [[self getCurrentTimeStamp] longLongValue];
    long time = [date timeIntervalSince1970]*1000;
    long per = 3600 * 24 * 1000;
    if(time - now > 0 &&  time - now <= per){
        return @"今天";
    }
    if(time - now <= 2 * per && time - now > per){
        return @"明天";
    }
    if(time - now <= 3 * per && time - now > 2 * per){
        return @"后天";
    }
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = [componets weekday];
    NSArray *weekArray = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    return weekArray[weekday-1];
}


+(NSMutableArray *)getOneWeeks{
    NSMutableArray *datas =[[NSMutableArray alloc]init];
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval=[dat timeIntervalSince1970]*1000;
    for(int i = 0 ; i < 7 ; i ++){
        timeInterval += 3600 * 24 * 1000;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval / 1000.0];
        NSString *dateStr = [self generateDate_CH:[NSString stringWithFormat:@"%.f",timeInterval]];
        NSString *weakStr = [self getCurrentWeek:date];
        dateStr = [dateStr substringWithRange:NSMakeRange(5, dateStr.length - 5)];
        NSString *result = [NSString stringWithFormat:@"%@ %@",dateStr,weakStr];
        [datas addObject:dateStr];
//        [STLog print:result];
    }
    return datas;
}


+(long)getTimeStamp:(NSString *)dateStr format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSDate* date = [formatter dateFromString:dateStr];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue] * 1000;//这里都搞成毫秒
    return (long)timeSp;
}

+(NSString *)getCallTime:(long)count{
    return [self generateDate:[NSString stringWithFormat:@"%ld",count * 1000] format:@"mm:ss"];
}


//+(NSString *)generateCourseDate:(NSString *)date{
//    if(!IS_NS_STRING_EMPTY(date) && [date containsString:@"-"]){
//        NSArray *dates = [date componentsSeparatedByString:@"-"];
//        int year = [dates[0] intValue];
//        int month = [dates[1] intValue];
//        if(month == 12){
//            return [NSString stringWithFormat:@"%02d-01-01",year+1];
//        }
//        return [NSString stringWithFormat:@"%02d-%02d-01",year,month+1];
//    }
//    return MSG_EMPTY;
//}

+(NSUInteger)getMaxDay:(NSString *)year month:(NSString *)month{
    NSString *dateStr =[NSString stringWithFormat:@"%@-%@",year,month];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate * date = [dateFormatter dateFromString:dateStr];
    
    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 通过该方法计算特定日期月份的天数
    NSRange monthRange =  [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return monthRange.length;
}

+(BOOL)isYesterday:(NSString *)timestamp {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    
    BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:date];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970]*1000;//当前时间戳
    NSTimeInterval targetTimeInterval = timestamp.floatValue;
    if (targetTimeInterval > currentTimeInterval) {
        return NO;//未来
    }else {
        return !isToday;
    }
}

+(BOOL)isThisYear:(NSString *)timestamp {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1. 转换目标时间戳为NSDate
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/ 1000.0];
    NSDateComponents *targetCmps = [calendar components:unit fromDate:date];
    
    // 2.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    return targetCmps.year == nowCmps.year;
}

@end
