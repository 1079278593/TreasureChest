//
//  FileManager.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/20.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "FileManager.h"
#import "URLDownloadTask.h"

static FileManager *manager = nil;
@interface FileManager ()

@end

@implementation FileManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FileManager alloc]init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return manager;
}

- (instancetype)init {
    if(self == [super init]){
        
    }
    return self;
}

#pragma mark - < public >
- (void)resourcePathWithType:(FilePathType)type foldName:(NSString *)foldName fileName:(NSString *)fileName url:(NSString *)url complete:(PathBlock)block {
    //这里或者外面，启动loading，待完成后‘结束loading’。
    NSString *rootPath = [self pathWithType:type];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",rootPath,foldName,fileName];
    if ([self createFoldWithType:type foldName:foldName]) {
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
    }else {
        block(@"");
    }
}

- (BOOL)deleteWithFileName:(NSString *)fileName type:(FilePathType)type {
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self pathWithType:type],fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:path];
    if (isExist) {
        return [manager removeItemAtPath:path error:nil];
    }
    return YES;
}

#pragma mark - < 增删查改 >
- (BOOL)createFoldWithType:(FilePathType)type foldName:(NSString *)foldName {
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self pathWithType:type],foldName];
    NSFileManager *manager = [NSFileManager defaultManager];
    
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

#pragma mark - < private >
- (NSString *)pathWithType:(FilePathType)type {
    switch (type) {
        case FilePathTypeRoot:
            return [NSString stringWithFormat:@"%@",KDocument];
            break;
        case FilePathTypeFaceBox:
            return [NSString stringWithFormat:@"%@",KFaceBoxPath];
            break;
        default:
            return [NSString stringWithFormat:@"%@",KDocument];
            break;
    }
}


@end
