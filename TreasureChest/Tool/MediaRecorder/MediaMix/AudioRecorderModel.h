//
//  AudioRecorderModel.h
//  TreasureChest
//
//  Created by xiao ming on 2020/4/10.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecorderModel : NSObject

@property(nonatomic, strong)NSString *sourcePath;
@property(nonatomic, assign)NSString *startTime;
@property(nonatomic, assign)int type;

@end

NS_ASSUME_NONNULL_END
