//
//  CheckAuthorization.h
//  TreasureChest
//
//  Created by xiao ming on 2020/3/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^CheckBlock)(BOOL result);

NS_ASSUME_NONNULL_BEGIN

@interface CheckAuthorization : NSObject

+ (void)checkAlbumAuthorizationStatus:(CheckBlock)isAgree;
+ (void)checkCameraAuthorizationStatus:(CheckBlock)isAgree;
+ (void)checkMicrophoneAuthorizationStatus:(CheckBlock)isAgree;

@end

NS_ASSUME_NONNULL_END
