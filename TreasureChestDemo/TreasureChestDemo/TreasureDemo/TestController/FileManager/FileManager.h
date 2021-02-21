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
 
 */

typedef void(^PathBlock)(NSString *path);

@interface FileManager : NSObject

+ (instancetype)shareInstance;
- (void)resourcePathWithType:(FilePathType)type foldName:(NSString *)foldName fileName:(NSString *)fileName url:(NSString *)url complete:(PathBlock)block;
- (BOOL)deleteWithFileName:(NSString *)fileName type:(FilePathType)type;

@end

NS_ASSUME_NONNULL_END
