//
//  URLDownloadTask.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "URLDownloadTask.h"

@interface URLDownloadTask()<NSURLSessionDownloadDelegate>

@property(nonatomic, strong)NSString *destinationFullPath;
@property(nonatomic, strong)NSURLSession *session;
@property(nonatomic, strong)NSData *resumeData;

@end

@implementation URLDownloadTask

- (instancetype)init {
    if(self == [super init]){
        
    }
    return self;
}

#pragma mark - < public >
- (void)setupTask:(NSString *)urlPath localPath:(NSString *)localPath {
    self.destinationFullPath = localPath;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
//    [self.downloadTask resume];
}

- (void)pauseDownload {
//    [self.downloadTask suspend];
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
           self.resumeData = resumeData;
       }];
}

- (void)continueDownload {
    if (self.downloadTask.state == NSURLSessionTaskStateCompleted) {
        if (self.resumeData) {
            //使用resumeData创建一个下载任务。如果无法成功恢复下载，将调用URLSession:task:didCompleteWithError:。
            self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
        }
    }
    [self.downloadTask resume];
}

- (void)stopDownload {
    //不可恢复
    [self.downloadTask cancel];
}

- (void)easyDownload:(NSString *)urlPath localPath:(NSString *)localPath isUpdate:(BOOL)isUpdate {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
            if (isUpdate) {
                [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];//删除
            }
            BOOL flag = [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:localPath] error:nil];
            if (flag) {
                if (self.progressBlock) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.progressBlock(1);
                        });
                    });
                }
            }else {
                printf("下载成功，移动文件到目标目录失败");
                self.progressBlock(1);//
            }
        }else {
            printf("下载失败");
            self.progressBlock(0);
        }
        
    }];
    [dataTask resume];
}

#pragma mark - < delegate >

/**
 * 写数据
 * @param bytesWritten 本次写入数据大小
 * @param totalBytesWritten 下载数据总大小
 * @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = 1.0 *totalBytesWritten/totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    NSLog(@"%.2f%%",100.0 *totalBytesWritten/totalBytesExpectedToWrite);
}

/**
* 恢复下载
* @param fileOffset 恢复从哪里位置下载
* @param expectedTotalBytes 文件总大小
*/
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

/**
 * 下载完成
 * @param location 文件临时存储路径
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
//    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    BOOL flag = [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.destinationFullPath] error:nil];
    if (flag) {
        NSLog(@"下载完成，移动成功：移动到目标目录：%@",self.destinationFullPath);
    }else {
        NSLog(@"下载完成，移动失败：源目录%@",location);
    }
}

/**
 * 请求结束
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        printf("成功");
    }else {
        printf("下载失败");
    }
}

@end
