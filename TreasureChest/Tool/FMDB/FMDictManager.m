//
//  FMDictManager.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FMDictManager.h"
#import "FMDBMacro.h"

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
        _datas = [NSMutableArray arrayWithCapacity:0];
        [self initDataBaseQueue];
    }
    return self;
}

- (void)initDataBaseQueue {
    self.tableName = DictTableName;
    NSString *path = DatabasePath(DictSmallDatabaseName);//DictNormalDatabaseName  //DictSuperDatabaseName //DictSmallDatabaseName
//    NSString *path = @"/Users/xiaoming/Desktop/ECDICT-master/dict_0.77million.db";
    self.dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
}

#pragma mark - <  >
- (void)requestTotalCount {
    [self.dataBaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;",self.tableName];
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE word MATCH 'acryl';",self.tableName];
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE rowid = '12';",self.tableName];
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE translation MATCH '压克力';",self.tableName];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            NSString *count = result[@"COUNT(*)"];
            NSLog(@"%@: count: %@ \n resultDictionary: %@",self.tableName,count,result.resultDictionary);
        }
    }];
}

/**
 参考：https://www.sqlite.org/fts3.html
   FTS tables 支持3种查询：
1. SELECT * FROM tableName WHERE docs MATCH 'lin*';   （含有：lin开头的）
1.1 SELECT * FROM docs WHERE body MATCH 'title: ^lin*'; （FTS4版本）

 
2.
-- Query for all documents that contain the phrase "linux applications".
SELECT * FROM docs WHERE docs MATCH '"linux applications"';

-- Query for all documents that contain a phrase that matches "lin* app*". As well as
-- "linux applications", this will match common phrases such as "linoleum appliances"
-- or "link apprentice".
SELECT * FROM docs WHERE docs MATCH '"lin* app*"';


3.
-- Search for a document that contains the terms "sqlite" and "database" with
-- not more than 10 intervening terms. This matches the only document in
-- table docs (since there are only six terms between "SQLite" and "database"
-- in the document).
SELECT * FROM docs WHERE docs MATCH 'sqlite NEAR database';
                   
//------------筛选前几个
NSString *sql = [NSString stringWithFormat:@"SELECT top 10 * FROM %@ WHERE word LIKE '%%%@%%' ORDER BY frq DESC;",self.tableName,keywords];//desc降序
NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE word LIKE '%%%@%%' LIMIT 0,10;",self.tableName,keywords];//取第0~10条数据
*/
//
- (void)requestWithKeywords:(NSString *)keywords {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self.dataBaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE word MATCH '%@*' AND (frq > 0 OR bnc > 0) ORDER BY (frq+bnc) ASC",self.tableName,keywords];
            if ([keywords containsString:@" "]) {
                sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE word MATCH '%@*' ORDER BY (frq+bnc) ASC LIMIT 10",self.tableName,keywords];
            }
            NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
            FMResultSet *result = [db executeQuery:sql];
            while ([result next]) {
//                if ([result[@"word"] caseInsensitiveCompare:keywords] == NSOrderedSame) {
//                    [self.results insertObject:result.resultDictionary atIndex:0];
//                }else {
                    [results addObject:result.resultDictionary];
//                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.datas = [DictionaryMainModel mj_objectArrayWithKeyValuesArray:results];
            });
        }];
    });
    
    
}
@end
