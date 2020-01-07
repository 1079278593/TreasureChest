//
//  NSDecimalNumber+Extension.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/2.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "NSDecimalNumber+Extension.h"

@implementation NSDecimalNumber (Extension)

#pragma mark - < 计算、比较、返回string >
+ (BOOL)isAGreaterThanB:(id)A valueB:(id)B {
    NSDecimalNumber *valueA = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",A]];
    NSDecimalNumber *valueB = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",B]];
    NSComparisonResult result = [valueA compare: valueB];
    //Descending(降序）:valueA > valueB;
    //Ascending(升序）:valueA < valueB;
    if (result == NSOrderedDescending) {
        return true;
    }
    return false;
}



#pragma mark - < 快捷方式1 >
+ (NSDecimalNumber *)roundPlain:(NSString *)valueString {
    return [self roundWithMode:NSRoundPlain value:valueString scale:2];
}

+ (NSDecimalNumber *)roundDown:(NSString *)valueString {
    return [self roundWithMode:NSRoundDown value:valueString scale:2];
}

+ (NSDecimalNumber *)roundUp:(NSString *)valueString {
    return [self roundWithMode:NSRoundUp value:valueString scale:2];
}

+ (NSDecimalNumber *)roundBankers:(NSString *)valueString {
    return [self roundWithMode:NSRoundBankers value:valueString scale:2];
}

#pragma mark - < 快捷方式2 >
+ (NSDecimalNumber *)roundPlain:(NSString *)valueString scale:(short)scale {
    return [self roundWithMode:NSRoundPlain value:valueString scale:scale];
}

+ (NSDecimalNumber *)roundDown:(NSString *)valueString scale:(short)scale {
    return [self roundWithMode:NSRoundDown value:valueString scale:scale];
}

+ (NSDecimalNumber *)roundUp:(NSString *)valueString scale:(short)scale {
    return [self roundWithMode:NSRoundUp value:valueString scale:scale];
}

+ (NSDecimalNumber *)roundBankers:(NSString *)valueString scale:(short)scale {
    return [self roundWithMode:NSRoundBankers value:valueString scale:scale];
}

#pragma mark - <  >
+ (NSDecimalNumber *)roundWithMode:(NSRoundingMode)mode value:(NSString *)valueString scale:(short)scale {
    NSDecimalNumberHandler *numberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:valueString];
    decimalNumber = [decimalNumber decimalNumberByRoundingAccordingToBehavior:numberHandler];
    return decimalNumber;
}

@end
