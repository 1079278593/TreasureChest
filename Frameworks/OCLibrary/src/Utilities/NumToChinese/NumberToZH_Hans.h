//
//  NumberToZH_Hans.h
//  Poppy_Dev01
//
//  Created by jf on 2020/11/27.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberToZH_Hans : NSObject

/**
 *  将阿拉伯数字转换为中文数字
 */
+ (NSString *)translationArabicNum:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END
