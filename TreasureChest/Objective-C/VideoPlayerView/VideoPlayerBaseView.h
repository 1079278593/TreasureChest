//
//  VideoPlayerBaseView.h
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FinishBlock)(void);
typedef void (^ProgressBlock)(CGFloat progress);

@interface VideoPlayerBaseView : UIImageView

@property(nonatomic, assign)CGFloat volume;
@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)AVPlayerItem *playerItme;

@property(nonatomic, copy)FinishBlock finishBlock;
@property(nonatomic, copy)ProgressBlock progressBlock;

- (void)setupPlayer:(NSString *)mediaPath;
- (void)startPlay;
- (void)startPlayAtTime:(CGFloat)second;
- (void)pausePlay;
- (void)stopPlay;

@end

NS_ASSUME_NONNULL_END
