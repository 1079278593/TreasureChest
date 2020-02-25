//
//  URLOfflineDownloadTask.h
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//  离线断点下载

/**
参考：https://www.jianshu.com/p/227e7c8b4858

1. 断点下载和离线断点下载区别：
1.1 断点下载是从内存中取出当前下载数据的 Size ，然后设置请求头的 Range
1.2 离线断点下载是从沙盒中取出已下载的数据的 Size ，然后设置请求头的 Range

2. 使用的task分别是：
2.1 断点下载：       NSURLSessionDownloadTask
2.2 离线断点下载：NSURLSessionDataTask
 

*/



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DownloadProgress)(CGFloat progress);
typedef void(^DownloadFail)(void);

@interface URLOfflineDownloadTask : NSObject

@property (nonatomic, copy)DownloadFail failBlock;
@property (nonatomic, copy)DownloadProgress progressBlock;
@property (nonatomic, strong)NSURLSessionDataTask *dataTask;

- (void)setupTask:(NSString *)urlPath localPath:(NSString *)localPath;

@end

NS_ASSUME_NONNULL_END
