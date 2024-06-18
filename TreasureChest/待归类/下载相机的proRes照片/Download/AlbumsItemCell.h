//
//  AlbumsItemCell.h
//  AwesomeCamera
//
//  Created by imvt on 2023/7/17.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryDownloadModel.h"
#import "CameraMediaItem.h"

NS_ASSUME_NONNULL_BEGIN
@protocol AlbumsItemCellDelegate <NSObject>

- (void)deleteSuccess:(GalleryDownloadModel *)model;

@end

@interface AlbumsItemCell : UICollectionViewCell

@property(nonatomic, weak)id<AlbumsItemCellDelegate> delegate;

- (void)refreshCellWithModel:(GalleryDownloadModel *)model;
- (void)hideEditButton:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
