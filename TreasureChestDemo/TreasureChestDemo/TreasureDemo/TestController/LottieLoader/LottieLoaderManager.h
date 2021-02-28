//
//  LottieLoaderManager.h
//  TreasureChest
//
//  Created by ming on 2021/2/28.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KLottieLoaderCacheCount 5   //缓存5个lottie动画，大于5的情况：释放当前最早缓存的lottie
NS_ASSUME_NONNULL_BEGIN

@interface LottieLoaderManager : NSObject

+ (instancetype)shareInstance;
- (void)loadWithPath:(NSString *)path url:(NSString *)url;
- (CVPixelBufferRef)pixelBufferWithProgress:(CGFloat)progress;
- (void)clean;

@end

NS_ASSUME_NONNULL_END
