//
//  URLDownloadTask.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "URLDownloadTask.h"

@interface URLDownloadTask()<NSURLSessionDownloadDelegate>

@property(nonatomic, strong)NSData *resumeData;
@property(nonatomic, strong)NSURLSession *session;
@property(nonatomic, strong)NSString *destinationFullPath;

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
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
    [downloadTask resume];
    self.downloadTask = downloadTask;
    
}

#pragma mark - < delegate >

/**
 * 写数据
 * @param bytesWritten 本次写入数据大小
 * @param totalBytesWritten 下载数据总大小
 * @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
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
        NSLog(@"成功：移动到目标目录：%@",self.destinationFullPath);
    }else {
        NSLog(@"失败：源目录%@",location);
    }
}

/**
 * 请求结束
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        NSLog(@"成功");
    }else {
        NSLog(@"下载失败：%@",error.localizedDescription);
    }
}

@end
