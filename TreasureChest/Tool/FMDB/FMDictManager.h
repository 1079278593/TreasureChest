//
//  FMDictManager.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FMDBManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMDictManager : FMDBManager

- (void)requestTotalCount;
- (void)requestWithKeywords:(NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
