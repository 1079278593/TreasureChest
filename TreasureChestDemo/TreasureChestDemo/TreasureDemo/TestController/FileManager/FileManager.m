//
//  FileManager.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/20.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "FileManager.h"
#import "URLDownloadTask.h"

#define KDocument NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject

@interface FileManager ()

@end

@implementation FileManager

#pragma mark - < public >
- (void)resourcePathFromFaceMaskName:(NSString *)maskName resourceName:(NSString *)resourceName url:(NSString *)url complete:(PathBlock)block {
    //这里或者外面，启动loading，待完成后‘结束loading’。
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",KDocument,maskName,resourceName];
    if ([self createFoldWithName:maskName]) {
        if ([self isExistFileWithPath:filePath]) {
            block(filePath);
        }else {
            URLDownloadTask *task = [[URLDownloadTask alloc]init];
            [task easyDownload:url localPath:filePath isUpdate:YES];
            task.progressBlock = ^(CGFloat progress) {
                if (progress == 1) {
                    block(filePath);
                }
            };
        }

    }
    block(@"");
}

#pragma mark - < 增删查改 >
- (BOOL)createFoldWithName:(NSString *)foldName {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@",KDocument,foldName];
    BOOL isExist = [manager fileExistsAtPath:path];
    if (!isExist) {
        NSError *error;
        return [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return YES;
}

- (BOOL)writeDataWithPath:(NSString *)path data:(NSData *)data {
    if ([self isExistFileWithPath:path]) {
        return [data writeToFile:path atomically:YES];
    }
    return NO;
}

- (BOOL)isExistFileWithPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:path];
    return isExist;
}

#pragma mark - < 下载，目前放这里，待放到单独的类 >
- (void)downloadFileWithUrl:(NSString *)url {
    

}


@end
