//
//  EasyPhotoLibrary.m
//  AwesomeCamera
//
//  Created by imvt on 2023/8/1.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "EasyPhotoLibrary.h"

@interface EasyPhotoLibrary ()


@end

@implementation EasyPhotoLibrary
//
//- (instancetype)init {
//    if (self = [super init]) {
//
//    }
//    return self;
//}

#pragma mark - < create & get >
+ (PHAssetCollection *)createdCollectionWithName:(NSString *)albumName {
    PHAssetCollection *collection = [self albumWithName:albumName];// 查询是否创建过相册
    if (collection) {
        return collection;
    }
    
    // 创建自定义相册
    __block NSString *identifier = nil;
    NSError *error = nil;

    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        identifier = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];

    if (error) return nil;

    collection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
    return collection;
}

///获取指定ablum内指定类型的资源
+ (NSMutableArray <PHFetchResult *> *)getAssetFetchResultsWithName:(NSString *)albumName type:(PHAssetMediaType)type {
    // 我的照片流
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];//用户创建相册
    NSArray *allAlbums = @[smartAlbums,topLevelUserCollections];
    
    NSMutableArray *albumArr = [NSMutableArray array];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            //遍历获取相册
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if (collection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
            if ([collection estimatedAssetCount] < 1) {
                NSLog(@"sub album , filter when asset count < 1"); continue;
            }
            NSString *collectionName = collection.localizedTitle;
            NSLog(@"sub album title is %@", collectionName);
            if (![collectionName isEqualToString:albumName]) {
                continue;
            }
            
            //获取当前相册里所有的PHAsset，也就是图片或者视频
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];//降序
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", type];
            if (type == PHAssetMediaTypeUnknown) {
                option = nil;
            }
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (assetsFetchResult.count > 0) {
                NSLog(@"sub album '%@' type~%lu count is %ld", collectionName, type, assetsFetchResult.count);
                [albumArr addObject:assetsFetchResult];
            }
        }
    }
    return albumArr;
}

+ (void)deleteAssetWithIdentifier:(NSString *)identifier handler:(PhotoRemoveComplete)block {
    PHFetchResult * fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
    PHAsset * asset = [fetchResult firstObject];
    if (asset != nil)
        
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[asset]];
    } completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"删除系统asset：%@",(success ? @"成功" : @"失败"));
        block(success);
    }];
}

#pragma mark - < save video >
+ (void)saveVideoAssetWithPath:(NSURL *)filePath toAlbum:(NSString *)albumName handler:(PhotoSaveComplete)block {
//    BOOL flag = [[NSFileManager defaultManager] fileExistsAtPath:filePath.absoluteString];
    __block NSString *localIdentifier;// 要保存到系统相册中视频的标识
    PHAssetCollection *collection = [self albumWithName:albumName];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //请求创建一个Asset
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:filePath];
        //为Asset创建一个占位符，放到相册编辑请求中
        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
        
        if (collection) {
            //请求编辑相册
            PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            //相册中添加视频
            [collectonRequest addAssets:@[placeHolder]];
        }
        
        localIdentifier = placeHolder.localIdentifier;
    } completionHandler:^(BOOL success, NSError *error) {
        block(success, localIdentifier);
    }];
}

#pragma mark - < save image >
+ (void)saveImage:(UIImage *)image toAlbum:(NSString *)albumName handler:(PhotoSaveComplete)block {
    __block NSString *localIdentifier;// 要保存到系统相册中的图片的标识
    PHAssetCollection *collection = [self albumWithName:albumName];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 请求创建一个Asset
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        // 为Asset创建一个占位符，放到相册编辑请求中
        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
        
        if (collection) {
            // 请求编辑相册
            PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            // 相册中添加照片
            [collectonRequest addAssets:@[placeHolder]];
        }
        
        localIdentifier = placeHolder.localIdentifier;
    } completionHandler:^(BOOL success, NSError *error) {
        block(success, localIdentifier);
    }];
}

+ (void)saveImageWithPath:(NSURL *)filePath toAlbum:(NSString *)albumName handler:(PhotoSaveComplete)block {
    __block NSString *localIdentifier;// 要保存到系统相册中的图片的标识
    PHAssetCollection *collection = [self albumWithName:albumName];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 请求创建一个Asset
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:filePath];
        // 为Asset创建一个占位符，放到相册编辑请求中
        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
        
        if (collection) {
            // 请求编辑相册
            PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            // 相册中添加照片
            [collectonRequest addAssets:@[placeHolder]];
        }
        
        localIdentifier = placeHolder.localIdentifier;
    } completionHandler:^(BOOL success, NSError *error) {
//        if (success) {
//            NSLog(@"保存图片成功!");
//        } else {
//            NSLog(@"保存图片失败:%@", error);
//        }
        block(success, localIdentifier);
    }];
}

#pragma mark - < private >
//目前使用这个
+ (PHAssetCollection *)albumWithName:(NSString *)albumName {
    if (albumName == nil) {
        return nil;
    }
    
    // 查询是否创建过相册
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in result) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            return collection;
        }
    }
    return nil;
}

#pragma mark - < 未使用 >
- (void)createPhotosAlbum:(NSString *)albumName {
    if (![self isExistPhotosAlbum:albumName]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];// 创建相册
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"创建相册文件夹成功!");
            } else {
                NSLog(@"创建相册文件夹失败:%@", error);
            }
        }];
    }
}

- (BOOL)isExistPhotosAlbum:(NSString *)albumName {
    //首先获取用户手动创建相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    __block BOOL isExisted = NO;
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        // albumName是自定义的要写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:albumName])  {
            isExisted = YES;
        }
    }];
    return isExisted;
}

@end
