//
//  EasyPhotoLibrary.h
//  AwesomeCamera
//
//  Created by imvt on 2023/8/1.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^PhotoSaveComplete)(BOOL success, NSString *localIdentifier);
typedef void(^PhotoRemoveComplete)(BOOL success);

@interface EasyPhotoLibrary : NSObject

+ (PHAssetCollection *)createdCollectionWithName:(NSString *)albumName;
+ (NSMutableArray <PHFetchResult *> *)getAssetFetchResultsWithName:(NSString *)albumName type:(PHAssetMediaType)type;
+ (void)deleteAssetWithIdentifier:(NSString *)identifier handler:(PhotoRemoveComplete)block;

+ (void)saveVideoAssetWithPath:(NSURL *)filePath toAlbum:(NSString *)albumName handler:(PhotoSaveComplete)block;

+ (void)saveImage:(UIImage *)image toAlbum:(NSString *)albumName handler:(PhotoSaveComplete)block;
+ (void)saveImageWithPath:(NSURL *)filePath toAlbum:(NSString *)albumName handler:(PhotoSaveComplete)block;

@end
