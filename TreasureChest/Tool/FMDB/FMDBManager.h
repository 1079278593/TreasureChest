//
//  FMDBManager.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDBManager : NSObject

+ (instancetype)sharedManager;

- (void)startCopy;

@end

NS_ASSUME_NONNULL_END
