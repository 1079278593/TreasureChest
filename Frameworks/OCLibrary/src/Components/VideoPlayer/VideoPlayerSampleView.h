//
//  VideoPlayerSampleView.h
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerBaseView.h"
//#import "UIImageView+VideoCover.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerSampleView : UIView

@property(nonatomic, strong)VideoPlayerBaseView *playerView;

- (void)setupPlayerWithMediaPath:(NSString *)mediaPath;

@end

NS_ASSUME_NONNULL_END
