//
//  MediaRecordModel.h
//  Poppy_Dev01
//
//  Created by jf on 2021/3/15.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AudioType) {
    AudioTypeRecord = 0,        //!< 录音
    AudioTypeEffect,            //!< 音效
    AudioTypeBgm,               //!< 背景音
};

NS_ASSUME_NONNULL_BEGIN

@interface MediaRecordModel : NSObject

@property(nonatomic, strong)NSString *path;
@property(nonatomic, assign)CGFloat volume;
@property(nonatomic, assign)BOOL isVideoNeedWaterMark;
@property(nonatomic, assign)AudioType audioType;

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *cover;

@end

NS_ASSUME_NONNULL_END
