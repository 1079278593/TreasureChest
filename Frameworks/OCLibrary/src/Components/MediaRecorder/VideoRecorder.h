//
//  VideoRecorder.h
//  TreasureChest
//
//  Created by 小明 on 2020/8/15.
//  Copyright © 2020 xiao ming. All rights reserved.
//  画面和音频一起录制

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RecordFinishBlock)(NSString *videoPath);

@interface VideoRecorder : NSObject

@property(nonatomic, assign)BOOL isDeviceOrientation;//是否根据设备的方向录制；默认NO，即UIDeviceOrientationPortrait的方向。要验证一下
@property(nonatomic ,strong)RecordFinishBlock finishBlock;
@property(nonatomic, strong, readonly)NSString *videoPath;

+ (instancetype)sharedInstance;
- (void)startWithRecorderView:(UIView *)recorderView;//无限时间，外部触发结束。帧率/刷新率用‘宏frameRate’控制。
- (void)startWithRecorderView:(UIView *)recorderView videoDuration:(CGFloat)duration;
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END


