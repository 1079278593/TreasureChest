//
//  FileManagerEnums.h
//  TreasureChest
//
//  Created by ming on 2021/2/21.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#ifndef FileManagerEnums_h
#define FileManagerEnums_h

#define KDocument NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject

#define KFaceBoxPath [NSString stringWithFormat:@"%@/FaceBox",KDocument]

typedef NS_ENUM(NSUInteger, FilePathType) {
    FilePathTypeRoot = 0,               //!< Document根目录
    FilePathTypeFaceBox,                //!< 假面盒子根目录
};

#endif /* FileManagerEnums_h */
