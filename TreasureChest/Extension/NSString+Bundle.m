//
//  NSString+Bundle.m
//  TreasureChest
//
//  Created by jf on 2020/12/28.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "NSString+Bundle.h"

@implementation NSString (Bundle)

+ (NSString *)getBundleShortVersion {
    return [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getBundleBuildVersion {
    return [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)getBundleVersion {
    NSString *shortVersion =  [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion =  [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ %@",shortVersion,buildVersion];
}

@end
