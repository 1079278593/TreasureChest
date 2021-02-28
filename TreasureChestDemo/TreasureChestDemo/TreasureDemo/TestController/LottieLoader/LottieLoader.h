//
//  LottieLoader.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/27.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LottieLoader : NSObject

- (CVPixelBufferRef)pixelBufferFromLottiePath:(NSString *)path url:(NSString *)url progress:(CGFloat)progress;
- (NSTimeInterval)getDuration;

@end

NS_ASSUME_NONNULL_END
