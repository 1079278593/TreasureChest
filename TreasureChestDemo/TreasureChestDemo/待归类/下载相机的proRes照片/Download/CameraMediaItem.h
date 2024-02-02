//
//  CameraMediaItem.h
//  TreasureChest
//
//  Created by imvt on 2023/10/7.
//  Copyright © 2023 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraMediaInfo : NSObject
@property (nonatomic) int w;
@property (nonatomic) int h;
@property (nonatomic) int duration;
@property (nonatomic) int rotation;

- (NSString*)resolutionText;

@end

@interface CameraMediaItem : NSObject

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) CameraMediaInfo *info;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) BOOL isSelect;

- (id)initWithFolderName:(NSString*)folderName fileName:(NSString*)fileName;
- (BOOL)isVideo;

@end

NS_ASSUME_NONNULL_END
