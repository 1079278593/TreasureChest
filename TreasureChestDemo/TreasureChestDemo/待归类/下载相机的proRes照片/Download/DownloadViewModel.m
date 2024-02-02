//
//  DownloadViewModel.m
//  AwesomeCamera
//
//  Created by imvt on 2023/7/18.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "DownloadViewModel.h"
#import "DownloadManager.h"
#import "EasyPhotoLibrary.h"
#import "DelayTimer.h"

@interface DownloadViewModel () <DownloadManagerDelegate>

@property(nonatomic, strong)DownloadManager *downloadManager;
@property(nonatomic, strong)DelayTimer *delayTimer;

@end

@implementation DownloadViewModel

- (instancetype)init {
    if (self = [super init]) {
        _datas = [NSMutableArray arrayWithCapacity:0];
        _delayTimer = [[DelayTimer alloc]init];
    }
    return self;
}

#pragma mark - < public >
- (void)prepareDatas {
    [self.datas removeAllObjects];
    
    NSMutableArray *remoteDatas = [self prepareRemoteDatas];
    
    NSMutableArray *sysDatas = [self prepareSysDatas];//重新加载本地相册
    
//    NSLog(@"remoteCount:%lu, sysCount:%lu",remoteDatas.count,sysDatas.count);
    
    [remoteDatas addObjectsFromArray:sysDatas];
    
    self.datas = remoteDatas;//rac
}

- (void)downloadResume {
    self.downloadManager.delegate = self;
    [self.downloadManager resume];
}

- (void)downloadPause {
    [self.downloadManager pause];
}

#pragma mark - DownloadManagerDelegate
- (void)updateDownloadInfo:(NSUInteger)index {
    //下载中，info可以看最新的下载进度
//    DownloadInfo *info = [self.downloadManager infoAtIndex:index];
    int targetIndex = (int)index;
    if (targetIndex < 0) {
        return;
    }
    self.reloadIndex = (int)index;//rac
}

- (void)doneDownload:(CameraMediaItem*)item {
    WS(weakSelf)//要等存到系统相册再刷新
    [self.delayTimer startTimeWithDelay:0.4 block:^{
        [weakSelf prepareDatas];//重新组装（Remote变成Local）
    }];
}

- (void)failedDownload:(CameraMediaItem*)item {
    [self prepareDatas];//重新组装，删除失败的
//    self.reloadEvent = YES;
}

- (void)removeDoneItemCompleted:(BOOL)success withError:(NSError *)error {
    self.reloadEvent = YES;
}


#pragma mark - < photo >
- (NSMutableArray *)prepareRemoteDatas {
    [self prepareDownloadItems];//手动准备要下载的数据
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    NSInteger count = [self.downloadManager numberOfDownloadItem];
    for (int i = 0; i<count; i++) {
        DownloadInfo *info = [self.downloadManager infoAtIndex:i];
        [results addObject:info];
    }
    return results;
}

#pragma mark 手动准备要下载的数据（本类是这个demo类，最主要的变更点）
- (void)prepareDownloadItems {
    
    CameraMediaItem *mediaItem = [[CameraMediaItem alloc]init];
    mediaItem.folderName = @"A001/";
    mediaItem.fileName = @"A001C0702_20190101051651_0001.MOV";
    
    NSString *host = @"http://192.168.31.67:80/DCIM/";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@%@",host,mediaItem.folderName,mediaItem.fileName,@"?act=thm"];
    mediaItem.url = [NSURL URLWithString:urlStr];
    mediaItem.info = [[CameraMediaInfo alloc]init];
    mediaItem.info.w = 1920;
    mediaItem.info.h = 1080;
    mediaItem.info.duration = 5;
    
    DownloadManager *download = [DownloadManager shareInstance];
    [download addMediaItem:mediaItem];
}

- (NSMutableArray *)prepareSysDatas {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *assetFetchResults = [EasyPhotoLibrary getAssetFetchResultsWithName:KAlbumName type:PHAssetMediaTypeUnknown];
    for (PHFetchResult *result in assetFetchResults) {//这里assetFetchResults数组长度是1，因为指定了albumName
        for (PHAsset *asset in result) {
            SysPhotoModel *item = [[SysPhotoModel alloc]init];
            item.asset = asset;
            [results addObject:item];
        }
    }
    return results;
}

#pragma mark - < getter >
- (DownloadManager *)downloadManager {
    if (_downloadManager == nil) {
        _downloadManager = [DownloadManager shareInstance];
    }
    return _downloadManager;
}

@end
