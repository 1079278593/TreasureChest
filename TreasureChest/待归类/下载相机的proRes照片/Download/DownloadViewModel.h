//
//  DownloadViewModel.h
//  AwesomeCamera
//
//  Created by imvt on 2023/7/18.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SysPhotoModel.h"
#import "DownloadInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadViewModel : NSObject

@property(nonatomic, strong)NSMutableArray <GalleryDownloadModel *> *datas;
@property(nonatomic, assign)BOOL reloadEvent;
@property(nonatomic, assign)int reloadIndex;

- (void)prepareDatas;

- (void)downloadResume;
- (void)downloadPause;

@end

NS_ASSUME_NONNULL_END
