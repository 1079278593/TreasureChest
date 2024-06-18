//
//  DownloadHeader.h
//  AwesomeCamera
//
//  Created by imvt on 2023/7/18.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#ifndef DownloadHeader_h
#define DownloadHeader_h

#define KAlbumName @"Z Camera"  //Album name in Photos app

typedef NS_ENUM(NSUInteger, DownloadStatus) {
    kDownloadStatusWaiting,
    kDownloadStatusDownloading,
    kDownloadStatusSaving,
    kDownloadStatusDone,
    kDownloadStatusFailedOutOfSpace,
    kDownloadStatusFailedNotCompatible,
    kDownloadStatusFailedNetwork,
};

@protocol GalleryDownloadProtocol <NSObject>

///判断是本地资源，还是相机的资源
- (BOOL)isLocalResource;

///判断是否是：视频
- (BOOL)isVideo;

///视频的时长，如果有
- (NSTimeInterval)videoDuration;

///相册用localIdentifier，Remote用URL地址的string
- (NSString *)url;

///返回MB
- (CGFloat)fileSize;

@end

#endif /* DownloadHeader_h */
