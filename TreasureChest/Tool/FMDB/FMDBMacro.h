//
//  FMDBMacro.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/11.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#ifndef FMDBMacro_h
#define FMDBMacro_h

#define SuperDictName @"dict_4million"
#define NormalDictName @"dict_3million"
#define SmallDictName @"dict_1million"

#define DictSuperDatabaseName [NSString stringWithFormat:@"%@.db",SuperDictName]
#define DictNormalDatabaseName [NSString stringWithFormat:@"%@.db",NormalDictName]
#define DictSmallDatabaseName [NSString stringWithFormat:@"%@.db",SmallDictName]

//#define DictSuperDatabaseName @"dict_4million.db"
//#define DictNormalDatabaseName @"dict_3million.db"
//#define DictSmallDatabaseName @"dict_1million.db"   //0.77million

#define DictTableName @"DictTable"

/**
 Documents：应用中用户数据可以放在这里，iTunes备份和恢复的时候会包括此目录
 tmp：存放临时文件，iTunes不会备份和恢复此目录，此目录下文件可能会在应用退出后删除
 Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
 */
#define DatabasePath(DatabaseName) [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:DatabaseName]


#endif /* FMDBMacro_h */
