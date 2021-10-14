//
//  UIColor+Extension.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/21.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)hexColor:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)hexColor:(NSString *)color
{
    return [self hexColor:color alpha:1.0f];
}


#pragma mark - < 以下参考 >
+ (UIColor *)fs_colorWithRGB:(NSUInteger)rgb alpha:(float)alpha {
    float r = ((float)((rgb & 0xFF0000) >> 16))/255.0;
    float g = ((float)((rgb & 0xFF00) >> 8))/255.0;
    float b = ((float)(rgb & 0xFF))/255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

+(UIColor *)colorWithHexString:(NSString*)hexString{
    NSString *valueString = hexString;
    valueString = [valueString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([valueString hasPrefix:@"0x"]){
        valueString = [hexString substringFromIndex:2];
    }
    if (valueString.length != 8 && valueString.length != 6){
        return nil;
    }
    
    unsigned color = 0;
    unsigned alpha = 255;
    if (valueString.length == 6){
        NSScanner *scanner = [NSScanner scannerWithString:valueString];
        [scanner scanHexInt:&color];
    }else{
        NSScanner *scanner = [NSScanner scannerWithString:[valueString substringToIndex:6]];
        [scanner scanHexInt:&color];
        scanner = [NSScanner scannerWithString:[valueString substringFromIndex:6]];
        [scanner scanHexInt:&alpha];
    }
    
    return [UIColor colorWithHex:color alpha:alpha/255.0f];
}

+(UIColor *)colorWithHex:(NSUInteger)color alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((color & 0xff0000) >> 16) / 255.0f
                           green:((color & 0xff00) >> 8) / 255.0f
                            blue:(color & 0xff) / 255.0f
                           alpha:alpha];
}



@end









