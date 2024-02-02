//
//  SysPhotoModel.h
//  AwesomeCamera
//
//  Created by imvt on 2023/7/17.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "GalleryDownloadModel.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface SysPhotoModel : GalleryDownloadModel

@property(nonatomic, strong)PHAsset *asset;//!< 本地

@end

NS_ASSUME_NONNULL_END
