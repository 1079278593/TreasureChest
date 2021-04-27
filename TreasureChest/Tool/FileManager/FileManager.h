//
//  FileManager.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/20.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileManagerEnums.h"

NS_ASSUME_NONNULL_BEGIN
/**
 包含：文件下载到沙盒、从沙盒获取对应的文件
 组织方式，以面具为文件夹，内部存储对应的文件：lut、tnn模型、Lottie
 待优化：这里的下载，和假面盒子有点耦合，主要是目录结构。现在做音乐下载时foldName就比较多余，所以有了KFaceBoxLottieFoldName这种宏
 */

typedef void(^PathBlock)(NSString *path);

@interface FileManager : NSObject

+ (instancetype)shareInstance;
///内部是异步下载，如果需要可以增加方法或者字段来实现同步下载。   待修改：fileName改成内部用URL来换取
- (void)resourcePathWithType:(FilePathType)type foldName:(NSString *)foldName fileName:(NSString *)fileName url:(NSString *)url complete:(PathBlock)block;

- (void)synResourcePathWithType:(FilePathType)type foldName:(NSString *)foldName fileName:(NSString *)fileName url:(NSString *)url complete:(PathBlock)block;
- (BOOL)createFoldWithType:(FilePathType)type foldName:(NSString *)foldName;
- (BOOL)deleteWithFileName:(NSString *)fileName type:(FilePathType)type;

@end

NS_ASSUME_NONNULL_END
