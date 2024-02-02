//
//  DownloadManager.h
//  AwesomeCamera
//
//  Created by chenpz on 14-8-7.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadInfo.h"

@class CameraMediaItem;

@protocol DownloadManagerDelegate <NSObject>

- (void)updateDownloadInfo:(NSUInteger)index;
- (void)doneDownload:(CameraMediaItem*)item;
- (void)failedDownload:(CameraMediaItem*)item;
- (void)removeDoneItemCompleted:(BOOL)success withError:(NSError *)error;

@end

@interface DownloadManager : NSObject

@property(nonatomic, weak)id <DownloadManagerDelegate> delegate;

+ (instancetype)shareInstance;

- (void)addMediaItem:(CameraMediaItem*)item;
- (void)removeMediaItemAtIndex:(NSInteger)index;

- (void)resume;
- (void)pause;

///准备下载
- (NSInteger)numberOfDownloadItem;
- (DownloadInfo*)infoAtIndex:(NSInteger)index;

///下载成功
- (NSInteger)numberOfDoneDownloadItem;
- (DownloadInfo*)infoForDoneAtIndex:(NSInteger)index;

///下载失败
- (NSInteger)numberOfFailedDownloadItem;
- (DownloadInfo*)infoForFailedAtIndex:(NSInteger)index;

- (void)addDoneDownloadedInfo:(DownloadInfo*)info;
- (void)redownloadFailedFileAtIndexPath:(NSUInteger)index;

@end
