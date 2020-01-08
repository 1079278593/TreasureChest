//
//  FMDictManager.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FMDictManager.h"

static FMDictManager *manager = nil;

@interface FMDictManager()

@property(strong, nonatomic) FMDatabaseQueue *dataBaseQueue;
@property(strong, nonatomic)NSString *tableName;

@end

@implementation FMDictManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDictManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if(self == [super init]){
//        [self initDataBaseQueue:@"dict_4million.db"];
        [self initDataBaseQueue:@"/Users/xiaoming/Desktop/ECDICT-master/dict_4million.db"];
        self.tableName = @"stardict";
    }
    return self;
}

- (void)initDataBaseQueue:(NSString *)path {
//    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *path = [docPath stringByAppendingPathComponent:dataBaseName];
    
    _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
}

#pragma mark - <  >
- (void)requestTotalCount {
    [self.dataBaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;",self.tableName];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            NSString *count = result[@"COUNT(*)"];
            NSLog(@"count: %@ resultDictionary: %@",count,result.resultDictionary);
        }
    }];
}

- (void)requestWithKeywords:(NSString *)keywords {
    [self.dataBaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//        NSString *sql = [NSString stringWithFormat:@"SELECT top 10 * FROM %@ WHERE word LIKE '%%%@%%' ORDER BY frq DESC;",self.tableName,keywords];//desc降序
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE word LIKE '%%%@%%' LIMIT 0,10;",self.tableName,keywords];//取第0~10条数据
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE word MATCH '%@';",self.tableName,keywords];
        FMResultSet *result = [db executeQuery:sql];
        int count = 0;
        while ([result next]) {
            count++;
            NSLog(@"resultDictionary: %@",result.resultDictionary);
        }
        NSLog(@"count: %d",count);
    }];
}

@end
