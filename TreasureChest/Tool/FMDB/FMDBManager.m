//
//  FMDBManager.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FMDBManager.h"
#import "FMDBMacro.h"

static FMDBManager *manager = nil;

@interface FMDBManager()

@property(strong, nonatomic) FMDatabaseQueue *originDataBaseQueue;
@property(strong, nonatomic) FMDatabaseQueue *targetDataBaseQueue;

@property(assign, nonatomic)int progress;
@property(assign, nonatomic)int totalCount;


@end

@implementation FMDBManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDBManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if(self == [super init]){
        self.progress = -1;

        [self initDataBaseQueue];
    }
    return self;
}

- (void)initDataBaseQueue {
    NSString *databaseName = DictSmallDatabaseName;
    
    //源数据
    NSString *originPath = [NSString stringWithFormat:@"/Users/ming/Desktop/ECDICT-master/%@",databaseName];
    _originDataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:originPath];
    
    //目标数据:从源数据拷贝
    NSString *targetPath = DatabasePath(databaseName);
    _targetDataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:targetPath];
    [self createVirtualTable:_targetDataBaseQueue tableName:DictTableName];
}

- (void)createVirtualTable:(FMDatabaseQueue *)queue tableName:(NSString *)tableName {
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"CREATE VIRTUAL TABLE %@ USING fts3 (word,sw,phonetic,definition,translation,pos,collins,oxford,tag,bnc,frq,exchange,detail,audio)",tableName];
        if ([db executeUpdate:sql]) {
            printf("table create success");
        }else {
            printf("table create fail");
        }
    }];
}

#pragma mark - < 开始拷贝 >
- (void)startCopy {
    NSString *tableName = @"stardict";
    [self.originDataBaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@;",tableName];
        FMResultSet *countResult = [db executeQuery:sql];
        while ([countResult next]) {
            self.totalCount = [countResult intForColumn:@"COUNT(*)"];
        }
        
        sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *result = [db executeQuery:sql];
        [self insertToTarget:result];
    }];
}

- (void)insertToTarget:(FMResultSet *)result {
    NSString *tableName = DictTableName;
    
    while ([result next]) {
        NSString *rid = result[@"id"];
        [self printProgress:rid];
        @autoreleasepool {
            [self.targetDataBaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                NSString *word = result[@"word"];
                NSString *sw = result[@"sw"];
                NSString *phonetic = result[@"phonetic"];
                NSString *definition = result[@"definition"];
                NSString *translation = result[@"translation"];
                NSString *pos = result[@"pos"];
                NSString *collins = result[@"collins"];
                NSString *oxford = result[@"oxford"];
                NSString *tag = result[@"tag"];
                NSString *bnc = result[@"bnc"];
                
                NSString *frq = result[@"frq"];
                NSString *exchange = result[@"exchange"];
                NSString *detail = result[@"detail"];
                NSString *audio = result[@"audio"];
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (word,sw,phonetic,definition,translation,pos,collins,oxford,tag,bnc,frq,exchange,detail,audio) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
                NSArray *values = @[word,sw,phonetic,definition,translation,pos,collins,oxford,tag,bnc,frq,exchange,detail,audio];
                BOOL flag = [db executeUpdate:sql withArgumentsInArray:values];//有特殊字符可以用‘withArgumentsInArray’方式。(比如：')

                if (!flag) {
                    [NSString stringWithFormat:@"插入错误,id：%@",rid];
                }
            }];
        }
    }
}

- (void)printProgress:(NSString *)currentIndex {
    int count = currentIndex.intValue;
    int newProgress = (count/(CGFloat)self.totalCount * 100);
    
    if (newProgress > self.progress) {
        NSLog(@"%d%%",newProgress);
        self.progress = newProgress;
    }
}

@end
