//
//  MediaMixture.h
//  Poppy_Dev01
//
//  Created by jf on 2021/3/4.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MergeCompletion)(NSString *outputPath);

@interface MediaMixture : NSObject

///合并视频和音频。（内部做了90度旋转，如果要更通用，传入角度，目前只有90度有处理，其它待增加）
- (void)mediaRecordWithVideo:(MediaRecordModel *)video audio:(MediaRecordModel *)audio bgmMusic:(MediaRecordModel *)bgmMusic withCompletion:(MergeCompletion)completion;

///导出带水印的视频
- (void)mediaOutputWithWaterMark:(MediaRecordModel *)video degrees:(CGFloat)degrees isNeedWaterMark:(BOOL)isNeedWaterMark  withCompletion:(MergeCompletion)completion;

- (NSString *)cachePath;

@end

NS_ASSUME_NONNULL_END
