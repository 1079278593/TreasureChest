//
//  NSDecimalNumber+Extension.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/2.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (Extension)

+ (BOOL)isAGreaterThanB:(id)A valueB:(id)B;


+ (NSDecimalNumber *)roundPlain:(NSString *)valueString;
+ (NSDecimalNumber *)roundPlain:(NSString *)valueString scale:(short)scale;

+ (NSDecimalNumber *)roundDown:(NSString *)valueString;
+ (NSDecimalNumber *)roundDown:(NSString *)valueString scale:(short)scale;

+ (NSDecimalNumber *)roundUp:(NSString *)valueString;
+ (NSDecimalNumber *)roundUp:(NSString *)valueString scale:(short)scale;

+ (NSDecimalNumber *)roundBankers:(NSString *)valueString;
+ (NSDecimalNumber *)roundBankers:(NSString *)valueString scale:(short)scale;

+ (NSDecimalNumber *)roundWithMode:(NSRoundingMode)mode value:(NSString *)valueString scale:(short)scale;

@end

NS_ASSUME_NONNULL_END
