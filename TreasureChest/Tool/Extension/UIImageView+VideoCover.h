//
//  UIImageView+VideoCover.h
//  TreasureChest
//
//  Created by xiao ming on 2020/4/2.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (VideoCover)

- (void)videoCoverWithvideoURL:(NSURL *)videoURL atTime:(NSTimeInterval)time;
- (void)videoCoverWithvideoURL:(NSURL *)videoURL atTime:(NSTimeInterval)time completed:(void (^)(UIImage *image))completeBlock;

@end

NS_ASSUME_NONNULL_END
