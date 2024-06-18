//
//  DownloadManager.m
//  AwesomeCamera
//
//  Created by chenpz on 14-8-7.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import "DownloadManager.h"
#import "GCDAsyncSocket.h"
#import <NSFileManager+FileSize.h>

#import "EasyPhotoLibrary.h"

#define DOWNLOAD_CACHE @"download_cache"

#define GCD_TAG_WRITE_REQUEST   (1)

#define GCD_TAG_READ_HEADER     (1)
#define GCD_TAG_READ_BODY       (2)

@interface DownloadManager () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)NSMutableArray *infoQueue;          //!< 正在下载（pending, running info queue）
@property(nonatomic, strong)NSMutableArray *doneInfoQueue;      //!< 完成下载（done info queue, include ok/ng）
@property(nonatomic, strong)NSMutableArray *failedInfoQueue;    //!< 下载失败
@property(nonatomic, strong)GCDAsyncSocket *socket;

@property(nonatomic, strong)CameraMediaItem *downloadingItem;
@property(nonatomic, strong)DownloadInfo *downloadingInfo;
@property(nonatomic, strong)NSFileHandle *currentFileHanle;

@property(nonatomic, strong)NSString *downloadPath;
@property(nonatomic, strong)NSString *folderName;

@property(nonatomic, assign)BOOL paused;

/* downloadSaveImageIndex is for a special case:
 *   when image is downloaded, and saving to ios album(index1);  *
 *   at the same time, User press cancel and will restart a new download (index2).
 *
 * Then when save image callback is deletage. self.downloadingInfo is changed, [self doneOneItem] is called,
 * and will finished the wrong index2;
 *
 */
@property (nonatomic) NSUInteger downloadSaveImageIndex;
@end

@implementation DownloadManager

+ (instancetype)shareInstance {
    static DownloadManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[DownloadManager alloc] init];
    });
    return shareInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSFileManager *fmg = [NSFileManager defaultManager];
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath, DOWNLOAD_CACHE];

        // create the cache folder if not exist
        NSError *error = nil;
        [fmg createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];

        // remove all the cached files
        self.folderName = path;
        NSDirectoryEnumerator *dirEnum = [fmg enumeratorAtPath:path];
        NSString *file;
        while ((file = [dirEnum nextObject])) {
            file = [self buildPathNameForFile:file];
            [fmg removeItemAtPath:file error:&error];
        }
    }
    return self;
}

#pragma mark - < public >
- (void)addMediaItem:(CameraMediaItem*)item {
    if (item == nil) {
        return;
    }
    // check duplicate
    for (DownloadInfo* oneInfo in self.infoQueue) {
        if ([oneInfo.item isEqual:item]) {
            return;
        }
    }
    DownloadInfo *info = [[DownloadInfo alloc] initWithItem:item];
    [self.infoQueue addObject:info];
}

- (void)removeMediaItemAtIndex:(NSInteger)index {
    if (index == 0) {
        [self cancelDownload];
    }

    [self removeInfoAtIndex:index];

    if (index == 0) {
        [self processNextRequest];
    }
}

- (void)resume {
    if (self.downloadingInfo == nil) {
        self.paused = NO;
        [self processNextRequest];
    } else if (self.paused){
        // break point
        [self downloadWithInfo:self.downloadingInfo];
		self.paused = NO;
    } else {
        NSLog(@"resume twice!!");
    }
}

- (void)pause {
    [self safeDisconnectSocket];
    self.paused = YES;
}

#pragma mark < 获取 >
- (NSInteger)numberOfDownloadItem {
    return [self.infoQueue count];
}

- (DownloadInfo*)infoAtIndex:(NSInteger)index {
    if (index >= [self.infoQueue count]) {
        return nil;
    }
    DownloadInfo *info = [self.infoQueue objectAtIndex:index];
    return info;
}

- (NSInteger)numberOfDoneDownloadItem {
    return [self.doneInfoQueue count];
}

- (DownloadInfo*)infoForDoneAtIndex:(NSInteger)index {
    if (index >= [self.doneInfoQueue count]) {
        return nil;
    }
    DownloadInfo *info = [self.doneInfoQueue objectAtIndex:index];
    return info;
}

- (NSInteger)numberOfFailedDownloadItem {
    return [self.failedInfoQueue count];
}

- (DownloadInfo*)infoForFailedAtIndex:(NSInteger)index {
    if (index >= [self.failedInfoQueue count]) {
        return nil;
    }
    DownloadInfo *info = [self.failedInfoQueue objectAtIndex:index];
    return info;
}

- (void)addDoneDownloadedInfo:(DownloadInfo *)info {
    if (info == nil) {
        return;
    }
    [self.doneInfoQueue addObject:info];
}

- (void)redownloadFailedFileAtIndexPath:(NSUInteger)index {
    NSUInteger indexNum = index - self.infoQueue.count;
    DownloadInfo *info = [self.failedInfoQueue objectAtIndex:indexNum];
    [self.infoQueue addObject:[[DownloadInfo alloc] initWithItem:info.item]];
    [self.failedInfoQueue removeObjectAtIndex:indexNum];
    if ([self.infoQueue count] == 1) {
        [self processNextRequest];
    }
}

#pragma mark - < private >
- (void)removeInfoAtIndex:(NSInteger)index {
    if (index < [self.infoQueue count]) {
        [self.infoQueue removeObjectAtIndex:index];
    } else {
        if (index == NSNotFound) {
            return;
        }
        NSLog(@"removeInfoAtIndex invalid:%ld", (long)index);
    }
}

- (void)addFailedInfo:(DownloadInfo *)info {
    for (DownloadInfo *downloadInfo in self.failedInfoQueue) {
        if ([downloadInfo.item.fileName isEqualToString:info.item.fileName]) {
            return;
        }
    }
    [self.failedInfoQueue addObject:info];
}



- (void)safeDisconnectSocket {
    if (self.socket != nil) {
        [self.socket setDelegate:nil];
        [self.socket disconnect];
    }
}



#pragma mark < start a download >
- (void)processNextRequest {
    self.downloadingInfo = nil;
    self.downloadingItem = nil;
    //[bug 1019]
    self.currentFileHanle = nil;

    // do not handle next
    if (self.paused) {
        return;
    }
    if ([self.infoQueue count] > 0) {
        DownloadInfo *info = [self.infoQueue objectAtIndex:0];
        [self downloadWithInfo:info];
    }
}

- (void)cancelDownload {
    [self safeDisconnectSocket];
    [self removeCachedFile];
}

- (void)downloadWithInfo:(DownloadInfo*)info {
    CameraMediaItem *item = info.item;
    self.downloadingInfo = info;
    self.downloadingItem = item;

//    NSString *str = [NSString stringWithFormat:@"http://%@:%d/DCIM/%@/%@", self.camera.ip, self.camera.port, item.folderName, item.fileName];
    NSURL *url = item.url;
    NSString *path = [self buildPathNameForFile:[url lastPathComponent]];
    NSFileManager *fmg = [NSFileManager defaultManager];
    if ([fmg fileExistsAtPath:path]) {

    } else if (![fmg createFileAtPath:path contents:nil attributes:nil]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleOutOfSpace];
        });
        return;
    }
    self.downloadPath = path;
    self.downloadingInfo.status = kDownloadStatusDownloading;
    [self.delegate updateDownloadInfo: 0];

    // send request to server
    NSError *error;
    NSString *request = [NSString stringWithFormat:
                         @"GET %@ HTTP/1.1\r\n"
                         "Range: bytes=%ld-\r\n"
                         "\r\n",
                         [url path],
                         (long)self.downloadingInfo.got
                         ];

    // Safe Guard
    // Setting self.socket to another socket, (if the socket is memory dealloc, disconnect is called;
    // so, set no delegate first.
    if (self.socket != nil) {
        [self.socket setDelegate:nil];
    }

    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.socket connectToHost:[url host] onPort:[[url port] unsignedShortValue] withTimeout:5 error:&error];
    [self.socket writeData:[request dataUsingEncoding:NSASCIIStringEncoding] withTimeout:5 tag:GCD_TAG_WRITE_REQUEST];

    NSLog(@"DownloadManager: %@", url);
}

- (void)removeCachedFile {
    NSFileManager *fmg = [NSFileManager defaultManager];
    [fmg removeItemAtPath:self.downloadPath error:nil];
}

#pragma mark - < 下载完成：成功或者失败 >
- (void)doneSave {
    self.downloadingInfo.status = kDownloadStatusDone;
    [self doneOneItem];

    NSLog(@"save done");
}

- (void)failedSave {
    self.downloadingInfo.status = kDownloadStatusFailedNotCompatible;
    [self doneOneItem];
}

- (void)doneOneItem {
    self.currentFileHanle = nil;

    NSUInteger index = [self.infoQueue indexOfObject:self.downloadingInfo];
    if (index == NSNotFound) {
        NSLog(@"index canceled!");
        return;
    }
    if (index != self.downloadSaveImageIndex) {
        NSLog(@"invalid index, maybe canceled");
        return;
    }

    [self.delegate updateDownloadInfo:index];
    [self removeInfoAtIndex:index];
    if (self.downloadingInfo.status == kDownloadStatusFailedNotCompatible) {
        [self addFailedInfo:self.downloadingInfo];
    } else {
        [self.doneInfoQueue addObject:self.downloadingInfo];
    }
    [self.delegate doneDownload:self.downloadingItem];

    [self removeCachedFile];
    [self processNextRequest];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {

}

/*
   This callback will only called when socket is closed by server side, or due to network problem.
   it will not be called when the socket is cancel, because we have already setDelegate:nil.
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        if (self.downloadingInfo.len != self.downloadingInfo.got || self.downloadingInfo.got == 0) {
            NSLog(@"download disconnect %@", err);
            [self handleDownloadVideoFailed];
        } else {
            NSLog(@"socketDidDisconnect Never!!! got:%lu %@", (long)self.downloadingInfo.got, err);
            [self handleDownloadVideoFailed];
        }
    } else {
        NSLog(@"socketDidDisconnect without error, Shit!!!");
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    NSLog(@"timeout read %ld", tag);
    [self handleDownloadVideoFailed];
    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    NSLog(@"timeout write");
    [self handleDownloadVideoFailed];
    return 0;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (![self.socket isEqual:sock]) {
        // Tag: [GCDAsyncSocketInnerProblem_001]
        // sock is already cancel.
        return;
    }
    if (GCD_TAG_READ_HEADER == tag) {
        // save this index for special case
        self.downloadSaveImageIndex = [self.infoQueue indexOfObject:self.downloadingInfo];

        NSInteger contentLength = [self parseContentLength:data];
        if (self.downloadingInfo.len == 0) {
            self.downloadingInfo.len = contentLength;
        }
        if (contentLength > 0) {
            uint64_t free = [NSFileManager getFreeDiskspace];
            if (free < contentLength + self.downloadingInfo.len + 50 *1024*1024) {
                [self handleOutOfSpace];
            } else {
                [sock readDataWithTimeout:10 tag:GCD_TAG_READ_BODY];
            }
        } else {
            [self handleDownloadVideoFailed];
        }

    } else if (GCD_TAG_READ_BODY == tag) {
        self.downloadingInfo.got += [data length];
        if (self.downloadingInfo.got <= self.downloadingInfo.len) {
            if (self.currentFileHanle == nil) {
                self.currentFileHanle = [NSFileHandle fileHandleForWritingAtPath:self.downloadPath];
                [self.currentFileHanle seekToEndOfFile];
            }
            [self.currentFileHanle writeData:data];

            if (self.downloadingInfo.got == self.downloadingInfo.len) {
                [self saveToPhotoAfterDownloaded];
            } else {
                [sock readDataWithTimeout:20 tag:GCD_TAG_READ_BODY];
            }

            [self.delegate updateDownloadInfo:[self.infoQueue indexOfObject:self.downloadingInfo]];
        } else {
            NSLog(@"didReadData with got: %ld > len: %ld", (long)self.downloadingInfo.got, (long)self.downloadingInfo.len);
            [self handleDownloadVideoFailed];
        }
    } else {
        NSLog(@"didReadData with unknown tag: %ld", tag);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == GCD_TAG_WRITE_REQUEST) {
        [sock readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:20 tag:GCD_TAG_READ_HEADER];
    }
}

#pragma mark < process >
- (void)handleDownloadVideoFailed {
    self.currentFileHanle = nil;
    self.downloadingInfo.status = kDownloadStatusFailedNetwork;

    NSUInteger index = [self.infoQueue indexOfObject:self.downloadingInfo];
    if (index != NSNotFound) {
        [self.delegate updateDownloadInfo:index];
        [self removeInfoAtIndex: index];
//        [self.doneInfoQueue addObject:self.downloadingInfo];
        [self addFailedInfo:self.downloadingInfo];
    }

    [self.delegate failedDownload:self.downloadingItem];

    [self removeCachedFile];
    [self safeDisconnectSocket];
    [self processNextRequest];
}

- (void)handleOutOfSpace {
    self.currentFileHanle = nil;
    self.downloadingInfo.status = kDownloadStatusFailedOutOfSpace;
    [self.delegate updateDownloadInfo:[self.infoQueue indexOfObject:self.downloadingInfo]];

    [self removeInfoAtIndex:[self.infoQueue indexOfObject:self.downloadingInfo]];
//    [self.doneInfoQueue addObject:self.downloadingInfo];
    [self addFailedInfo:self.downloadingInfo];
    [self.delegate failedDownload:self.downloadingItem];

    [self removeCachedFile];
    //[self.socket disconnect];
    [self safeDisconnectSocket];
    [self processNextRequest];
}

#pragma mark < save file to Photo >
- (void)saveToPhotoAfterDownloaded {
    [self.currentFileHanle closeFile];
    NSURL *filePath = [NSURL URLWithString:self.downloadPath];

    if ([[filePath lastPathComponent] rangeOfString:@".JPG"].location != NSNotFound) {
        self.downloadingInfo.status = kDownloadStatusSaving;
        [self.delegate updateDownloadInfo:self.downloadSaveImageIndex];

        UIImage *image = [UIImage imageWithContentsOfFile:self.downloadPath];
        [EasyPhotoLibrary saveImage:image toAlbum:KAlbumName handler:^(BOOL success, NSString *localIdentifier) {
            /*
             if download pictrue ,in some device ,the will call this function twice ;
             in order to avoid this thing, add  this:
             if (self.downloadingInfo.status != kDownloadStatusSaving){return};
             *
             */
            if (self.downloadingInfo.status != kDownloadStatusSaving) {
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    [self failedSave];
                } else {
                    [self doneSave];
                }
            });
            
        }];
    } else {
        BOOL flag = [[NSFileManager defaultManager] fileExistsAtPath:filePath.path];
        self.downloadingInfo.status = kDownloadStatusSaving;
        [self.delegate updateDownloadInfo:self.downloadSaveImageIndex];
        [EasyPhotoLibrary saveVideoAssetWithPath:filePath toAlbum:KAlbumName handler:^(BOOL success, NSString *localIdentifier) {
            /*
             if download pictrue ,in some device ,the will call this function twice ;
             in order to avoid this thing, add  this:
             if (self.downloadingInfo.status != kDownloadStatusSaving){return};
             *
             */
            if (self.downloadingInfo.status != kDownloadStatusSaving) {
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    [self failedSave];
                } else {
                    [self doneSave];
                }
            });
        }];
    }
}

#pragma mark - < getter >
- (NSString*)buildPathNameForFile:(NSString*)fileName {
    return [NSString stringWithFormat:@"%@/%@", self.folderName, fileName];
}

- (NSMutableArray*)infoQueue {
    if (_infoQueue == nil) {
        _infoQueue = [[NSMutableArray alloc] init];
    }
    return _infoQueue;
}

- (NSMutableArray*)doneInfoQueue {
    if (_doneInfoQueue == nil) {
        _doneInfoQueue = [[NSMutableArray alloc] init];
    }
    return _doneInfoQueue;
}

- (NSMutableArray*)failedInfoQueue {
    if (_failedInfoQueue == nil) {
        _failedInfoQueue = [[NSMutableArray alloc] init];
    }
    return _failedInfoQueue;
}

- (NSInteger)parseContentLength:(NSData*)data {
    NSString *header = [[NSString alloc] initWithBytes:[data bytes] length:[data length] -1 encoding:NSASCIIStringEncoding];
    NSArray *headers = [header componentsSeparatedByString:@"\r\n"];
    for (NSString *h in headers) {
        NSArray *p = [h componentsSeparatedByString:@":"];
        if ([p count] == 2) {
            if ([@"Content-Length" compare:p[0] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSString *value = p[1];
                return [value integerValue];
            }
        }
    }
    return 0;
}

@end
