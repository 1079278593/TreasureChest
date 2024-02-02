//
//  DownloadInfo.m
//  AwesomeCamera
//
//  Created by imvt on 2023/7/18.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "DownloadInfo.h"

@implementation DownloadInfo

- (id)initWithItem:(CameraMediaItem*)item; {
    self = [super init];
    if (self) {
        _got = 0;
        _len = 0;
        _status = kDownloadStatusWaiting;
        _item = item;
    }
    return self;
}

#pragma mark - < protocol >
- (BOOL)isLocalResource {
    return NO;
}

- (BOOL)isVideo {
    return [self.item isVideo];
}

- (NSTimeInterval)videoDuration {
    return [self.item.info duration];
}

- (NSString *)url {
    return [self.item url].absoluteString;
}

- (CGFloat)fileSize {
    return self.len / 1024 / 1024.0;
}

@end
