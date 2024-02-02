//
//  PingManager.h
//  TreasureChest
//
//  Created by imvt on 2024/2/1.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PingManager : NSObject

+ (instancetype)shareInstance;
- (void)startWithHost:(NSString *)host;
- (NSArray *)reachabilitiesFromHosts:(NSSet *)hosts;

@end

NS_ASSUME_NONNULL_END
