//
//  AudioPlayer.h
//  Poppy_Dev01
//
//  Created by jf on 2020/9/22.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayer : NSObject

+ (instancetype)shareInstance;

///比如：[[AudioPlayer shareInstance] playSound:@"游戏开始" fileType:@"m4a"];
- (void)playSound:(NSString *)fileName fileType:(NSString *)fileType;
- (void)playSound:(NSString *)filePath;
- (void)stopSound;

@end

NS_ASSUME_NONNULL_END
