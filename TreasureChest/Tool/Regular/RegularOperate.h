//
//  RegularOperate.h
//  TreasureChest
//
//  Created by xiao ming on 2020/2/28.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegularOperate : NSObject

//APP版本
+(double)getAppVersion;

//手机号是否有效
+(Boolean)isPhoneNumValid:(NSString *)phoneNum;

//身份证号码是否有效
+(Boolean)isIdNumberValid:(NSString *)idNum;

//判断是否纯数字
+ (BOOL)isPureNumber:(NSString *)str;

//判断是否为小数
+ (BOOL)isDecimal:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
