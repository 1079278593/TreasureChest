//
//  UploadFileConnection.h
//  Lighting
//
//  Created by imvt on 2021/12/10.
//  传文件到手机（手机是’服务器‘角色）

#import "HTTPConnection.h"

#define KUploadFileName @"upload.html"
#define KUploadFilePath @"/upload.html"

NS_ASSUME_NONNULL_BEGIN

@interface UploadFileConnection : HTTPConnection

@end

NS_ASSUME_NONNULL_END
