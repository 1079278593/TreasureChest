//
//  AlbumsItemCell.m
//  AwesomeCamera
//
//  Created by imvt on 2023/7/17.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "AlbumsItemCell.h"
#import "EasyPhotoLibrary.h"
#import "DownloadInfo.h"
#import "SysPhotoModel.h"

@interface AlbumsItemCell ()

@property(nonatomic, strong)GalleryDownloadModel *model;

@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *videoDurationLabel;
@property(nonatomic, strong)UILabel *fileSizeLabel;
@property(nonatomic, strong)UILabel *videoResolutionLabel;

@property(nonatomic, strong)UILabel *progressLabel;
@property(nonatomic, strong)UIButton *trashButton;

@end

@implementation AlbumsItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        _videoDurationLabel.hidden = YES;
        _progressLabel.hidden = YES;
    }
    return self;
}

#pragma mark - < public >
- (void)refreshCellWithModel:(GalleryDownloadModel *)model {
    self.model = model;
    BOOL isLocalResource = [model isLocalResource];
    BOOL isVideo = [model isVideo];
    
    self.videoDurationLabel.hidden = !isVideo;
//    self.videoDurationLabel.text = [TimeClockString second2Date:model.videoDuration];
    self.progressLabel.hidden = isLocalResource;
    self.fileSizeLabel.text = [NSString stringWithFormat:@"%.2fMB",[model fileSize]];
    
    //视频的分辨率
    self.videoResolutionLabel.text = @"";
    if (isVideo) {
        CameraMediaInfo *info;
        if (isLocalResource) {
            SysPhotoModel *sysModel = (SysPhotoModel *)model;
            info = [CameraMediaInfo new];
            info.w = (int)sysModel.asset.pixelWidth;
            info.h = (int)sysModel.asset.pixelHeight;
        }else {
            DownloadInfo *infoModel = (DownloadInfo *)model;
            info = infoModel.item.info;
        }
        self.videoResolutionLabel.text = [info resolutionText];
    }
    
    if (isLocalResource) {
        [self requestImageWithAssetIdetifier:[model url]];
    }else {
        DownloadInfo *infoModel = (DownloadInfo *)model;
        [self requestImageWithItem:infoModel.item];
        
        NSInteger got = infoModel.got / 1024 / 1024;
        NSInteger len = infoModel.len / 1024 / 1024;
        if (len == 0) {
            self.progressLabel.text = [NSString stringWithFormat:@"%dMB/%dMB", 0, 0];
        }else if(got == len) {
            self.progressLabel.text = @"";
            self.progressLabel.hidden = YES;
        } else {
            self.progressLabel.text = [NSString stringWithFormat:@"%ldMB/%ldMB", (long)got, (long)len];
        }
        if (!infoModel.isVideo) {
            self.progressLabel.hidden = YES;
        }
//        self.trashButton.hidden = YES;
        if (got < len && infoModel.isVideo) {
            self.trashButton.hidden = YES;//视频 且 下载中
        }
    }
}

- (void)hideEditButton:(BOOL)isHidden {
    self.trashButton.hidden = isHidden;
}

#pragma mark - < event >
- (void)closeButtonEvent:(UIButton *)button {
    [EasyPhotoLibrary deleteAssetWithIdentifier:self.model.url handler:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(deleteSuccess:)]) {
                    [self.delegate deleteSuccess:self.model];
                }
            });
        }
    }];
    //取消下载；如果是Remote
    //        [self.downloadMgr removeMediaItemAtIndex:[indexPath row]];
}

#pragma mark - < photo >
- (void)requestImageWithAssetIdetifier:(NSString *)assetIdentifier {//待封装到....
    __weak AlbumsItemCell *weakSelf = self;
    PHFetchResult * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil];
    PHAsset * asset = [fetchResult firstObject];
    if (asset != nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = NO;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = result;
            });
        }];
    }
}

- (void)requestImageWithItem:(CameraMediaItem *)item {
    [self.imageView sd_setImageWithURL:item.url placeholderImage:[UIImage imageNamed:@"ic_image_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

    }];
}

#pragma mark - < init view >
- (void)setupSubviews {
    _imageView = [[UIImageView alloc]init];
    [self.contentView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _fileSizeLabel = [[UILabel alloc]init];
    _fileSizeLabel.textAlignment = NSTextAlignmentLeft;
    _fileSizeLabel.font = [UIFont systemFontOfSize:12];
    _fileSizeLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_fileSizeLabel];
    [_fileSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(4);
        make.width.equalTo(@130);
        make.height.equalTo(@13);
    }];
    
    _videoDurationLabel = [[UILabel alloc]init];
    _videoDurationLabel.textAlignment = NSTextAlignmentRight;
    _videoDurationLabel.font = [UIFont systemFontOfSize:12];
    _videoDurationLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_videoDurationLabel];
    [_videoDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.contentView).offset(-4);
        make.width.equalTo(@130);
        make.height.equalTo(@13);
    }];
    
    _videoResolutionLabel = [[UILabel alloc]init];
    _videoResolutionLabel.textAlignment = NSTextAlignmentLeft;
    _videoResolutionLabel.font = [UIFont systemFontOfSize:12];
    _videoResolutionLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_videoResolutionLabel];
    [_videoResolutionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-4);
        make.left.equalTo(self.contentView).offset(4);
        make.width.equalTo(@130);
        make.height.equalTo(@13);
    }];
    
    _progressLabel = [[UILabel alloc]init];
    _progressLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.font = [UIFont systemFontOfSize:12];
    _progressLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _trashButton.hidden = YES;
    _trashButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_trashButton setImage:[UIImage imageNamed:@"gallery_deleteBtn"] forState:UIControlStateNormal];
    [_trashButton addTarget:self action:@selector(closeButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_trashButton];
    [_trashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-6);
        make.width.equalTo(@(66));
        make.height.equalTo(@(30));
    }];
}

@end
