//
//  FMDBManager.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FMDBManager.h"

static FMDBManager *manager = nil;

@interface FMDBManager()

@property(strong, nonatomic) FMDatabaseQueue *dataBaseQueue;

@end

@implementation FMDBManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDBManager alloc] init];
    });
    return manager;
}


- (void)initDataBaseQueue:(NSString *)path {
//    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *path = [docPath stringByAppendingPathComponent:dataBaseName];
    
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
}

@end
