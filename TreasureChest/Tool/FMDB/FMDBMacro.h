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

#define DatabasePath(DatabaseName) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:DatabaseName]


#endif /* FMDBMacro_h */
