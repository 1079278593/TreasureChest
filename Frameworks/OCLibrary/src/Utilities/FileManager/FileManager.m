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

@property(nonatomic, strong)URLDownloadTask *downloadTask;

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
//            NSLog(@"FileManager 同步 本地文件存在=%@",fileName);
            block(filePath);
        }else {
            block(@"");//这里不等待，直到下载完成，走上面的分支。
            if (!self.downloadTask.isDownloading) {
                [self.downloadTask easyDownload:url localPath:filePath isUpdate:YES];
                self.downloadTask.progressBlock = ^(CGFloat progress) {
                    if (progress == 1) {
//                        NSLog(@"FileManager 同步下载完成");
                    }
                };
            }
        }
    }else {
        block(@"");
    }
}

- (void)synResourcePathWithType:(FilePathType)type foldName:(NSString *)foldName fileName:(NSString *)fileName url:(NSString *)url complete:(PathBlock)block {
    if (fileName.length <=0 ) {
        block(@"");
        NSLog(@"FileManager 异步 文件名为空");
        return;
    }
    //这里或者外面，启动loading，待完成后‘结束loading’。
    NSString *rootPath = [self pathWithType:type];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",rootPath,foldName,fileName];
    if ([self createFoldWithType:type foldName:foldName]) {
        if ([self isExistFileWithPath:filePath]) {
            block(filePath);
            NSLog(@"FileManager 异步 本地文件存在=%@",fileName);
        }else {
//            if (!self.downloadTask.isDownloading) {
            self.downloadTask = [[URLDownloadTask alloc]init];
                [self.downloadTask easyDownload:url localPath:filePath isUpdate:YES];
                self.downloadTask.progressBlock = ^(CGFloat progress) {
                    if (progress == 1) {
                        block(filePath);
                        NSLog(@"FileManager异步下载完成=%@",fileName);
                    }
                    else{
                        block(@"");
                        NSLog(@"FileManager异步下载失败=%@",fileName);
                    }
                };
//            }
        }
    }else {
        NSLog(@"FileManager异步创建路径失败失败=%@",fileName);
        block(@"-----");
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
            return [NSString stringWithFormat:@"%@/FaceBox",KDocument];
            break;
        case FilePathTypeMusic:
            return [NSString stringWithFormat:@"%@",KDocument];
            break;
        case FilePathTypeVideo:
            return [NSString stringWithFormat:@"%@",KDocument];
            break;
        default:
            return [NSString stringWithFormat:@"%@",KDocument];
            break;
    }
}

- (URLDownloadTask *)downloadTask {
    if (_downloadTask == nil) {
        _downloadTask = [[URLDownloadTask alloc]init];
    }
    return _downloadTask;
}

@end
