//
//  FMDictManager.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FMDBManager.h"
#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDictManager : NSObject

+ (instancetype)sharedManager;

- (void)requestTotalCount;
- (void)requestWithKeywords:(NSString *)keywords;//英文
- (void)requestWithTranslation:(NSString *)keywords;//中文

@end

NS_ASSUME_NONNULL_END
