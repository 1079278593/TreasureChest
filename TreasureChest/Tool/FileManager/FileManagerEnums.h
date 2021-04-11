//
//  FileManagerEnums.h
//  TreasureChest
//
//  Created by ming on 2021/2/21.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#ifndef FileManagerEnums_h
#define FileManagerEnums_h

//根目录
#define KDocument NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject

//假面盒子根目录
//#define KFaceBoxPath [NSString stringWithFormat:@"%@/FaceBox",KDocument]


//lottie存放目录的文件夹名称。（在‘假面盒子根目录’下级）
#define KFaceBoxLottieFoldName @"Lottie"
//分割（扣人像）存放目录的文件夹名称。（在‘假面盒子根目录’下级）
#define KFaceBoxSplitModelFoldName @"Split"

//存放下载的音乐
#define KMusicFoldName @"Music"
//存放下载的视频
#define KVideoFoldName @"Video"

typedef NS_ENUM(NSUInteger, FilePathType) {
    FilePathTypeRoot = 0,               //!< Document根目录
    FilePathTypeFaceBox,                //!< 假面盒子根目录
    FilePathTypeMusic,                  //!< 音乐根目录
    FilePathTypeVideo,                  //!< 视频根目录
};

#endif /* FileManagerEnums_h */
