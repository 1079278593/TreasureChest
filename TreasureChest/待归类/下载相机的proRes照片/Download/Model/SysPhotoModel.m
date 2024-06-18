//
//  SysPhotoModel.m
//  AwesomeCamera
//
//  Created by imvt on 2023/7/17.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "SysPhotoModel.h"

@implementation SysPhotoModel

#pragma mark - < protocol >
- (BOOL)isLocalResource {
    return YES;
}

- (BOOL)isVideo {
    return (self.asset.mediaType == PHAssetMediaTypeVideo);
}

- (NSTimeInterval)videoDuration {
    return self.asset.duration;
}

- (NSString *)url {
    return self.asset.localIdentifier;
}

- (CGFloat)fileSize {
    PHAssetResource *resource = [PHAssetResource assetResourcesForAsset:self.asset].firstObject;
    NSInteger len = [[resource valueForKey:@"fileSize"] intValue];
    return len / 1024 / 1024.0;
}

@end
