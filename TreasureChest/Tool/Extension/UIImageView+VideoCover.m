//
//  UIImageView+VideoCover.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/2.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "UIImageView+VideoCover.h"
#import <SDWebImage/SDImageCache.h>
#import <AVFoundation/AVFoundation.h>

@implementation UIImageView (VideoCover)

- (void)videoCoverWithvideoURL:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    [self videoCoverWithvideoURL:videoURL atTime:time completed:^(UIImage *image) {
        
    }];
}

- (void)videoCoverWithvideoURL:(NSURL *)videoURL atTime:(NSTimeInterval)time completed:(void (^)(UIImage *image))completeBlock {
    //先从缓存中查找是否有图片
    SDImageCache *cache =  [SDImageCache sharedImageCache];
    UIImage *memoryImage =  [cache imageFromMemoryCacheForKey:videoURL.absoluteString];
    if (memoryImage) {
        self.image = memoryImage;
        completeBlock(memoryImage);
        return;
    }else{
        //再从磁盘中查找是否有图片
        UIImage *diskImage =  [cache imageFromDiskCacheForKey:videoURL.absoluteString];
        if (diskImage) {
            self.image = diskImage;
            completeBlock(diskImage);
            return;
        }
    }
    if (!time) {
        time = 1;
    }
    //如果都不存在，开启异步线程截取对应时间点的画面，转成图片缓存至磁盘
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        CGImageRef thumbnailImageRef = NULL;
        CFTimeInterval thumbnailImageTime = time;
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
        if(!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            SDImageCache * cache =  [SDImageCache sharedImageCache];
            [cache storeImage:thumbnailImage forKey:videoURL.absoluteString toDisk:YES];
            self.image = thumbnailImage;
            completeBlock(thumbnailImage);
        });
    });
}


@end
