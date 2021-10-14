//
//  URLDownloadTask.h
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DownloadProgress)(CGFloat progress);

@interface URLDownloadTask : NSObject

@property(nonatomic, assign)BOOL isDownloading;
@property (nonatomic, copy)DownloadProgress progressBlock;

- (void)easyDownload:(NSString *)urlPath localPath:(NSString *)localPath isUpdate:(BOOL)isUpdate;

@end

NS_ASSUME_NONNULL_END
