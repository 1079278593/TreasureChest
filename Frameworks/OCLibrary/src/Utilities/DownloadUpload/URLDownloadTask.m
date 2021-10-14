//
//  URLDownloadTask.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "URLDownloadTask.h"

@interface URLDownloadTask()

@end

@implementation URLDownloadTask

- (instancetype)init {
    if(self == [super init]){
        
    }
    return self;
}

- (void)easyDownload:(NSString *)urlPath localPath:(NSString *)localPath isUpdate:(BOOL)isUpdate {
    self.isDownloading = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.isDownloading = NO;
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

@end
