//
//  DownloadInfo.h
//  AwesomeCamera
//
//  Created by imvt on 2023/7/18.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "GalleryDownloadModel.h"
#import "CameraMediaItem.h"

NS_ASSUME_NONNULL_BEGIN

@class CameraMediaItem;

@interface DownloadInfo : GalleryDownloadModel

- (id)initWithItem:(CameraMediaItem*)item;

@property(nonatomic, strong)CameraMediaItem *item;
@property(nonatomic, assign)NSInteger got;//已读取
@property(nonatomic, assign)NSInteger len;
@property(nonatomic, assign)DownloadStatus status;
@property(nonatomic, strong)NSURL *assetURL;

@end

NS_ASSUME_NONNULL_END
