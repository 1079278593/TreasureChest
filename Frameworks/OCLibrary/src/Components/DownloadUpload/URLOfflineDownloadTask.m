//
//  URLOfflineDownloadTask.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "URLOfflineDownloadTask.h"


@interface URLOfflineDownloadTask()<NSURLSessionDelegate>

@property(nonatomic, assign)NSInteger totalSize;
@property(nonatomic, assign)NSInteger currentSize;
@property(nonatomic, strong)NSFileHandle *fileHandle;
@property (nonatomic, strong)NSURLSessionDataTask *dataTask;

@end

@implementation URLOfflineDownloadTask

- (instancetype)init {
    if(self == [super init]){
        
    }
    return self;
}

#pragma mark - < public >
- (void)setupTask:(NSString *)urlPath localPath:(NSString *)localPath {
    
    NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:localPath error:nil];
    self.currentSize = [[fileDict valueForKey:@"NSFileSize"] integerValue];
    if (self.currentSize == 0) {
        [[NSFileManager defaultManager] createFileAtPath:localPath contents:nil attributes:nil];
    }
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:localPath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [session dataTaskWithRequest:request];
}

- (void)pauseDownload {
    [self.dataTask suspend];
}

- (void)continueDownload {
    [self.dataTask resume];
}

#pragma mark - < NSURLSessionDelegate >
//1.接收服务器的响应，completionHandler回调传给系统（默认取消该请求：NSURLSessionResponseCancel）
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    self.totalSize = response.expectedContentLength+self.currentSize;
    if (self.totalSize <= self.currentSize) {
        completionHandler(NSURLSessionResponseCancel);//cancel会触发didCompleteWithError
    }else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    self.currentSize += data.length;
    CGFloat progress = 1.0 * self.currentSize / self.totalSize;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    NSLog(@"%.2f %%",100.0*progress);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self.fileHandle closeFile];
    self.fileHandle = nil;

    if (error != nil) {
        NSLog(@"did Completed With Error: %@",error.localizedDescription);
        if (self.totalSize <= self.currentSize) {
            //已经完成下载
            if (self.progressBlock) {
                self.progressBlock(1);
            }
        }else {
            if (self.failBlock) {
                self.failBlock();
            }
        }
    }else {
        //成功
    }
}

@end
