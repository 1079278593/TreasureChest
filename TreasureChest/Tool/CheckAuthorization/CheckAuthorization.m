//
//  CheckAuthorization.m
//  TreasureChest
//
//  Created by xiao ming on 2020/3/26.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "CheckAuthorization.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CheckAuthorization

#pragma mark - < album >
+ (void)checkAlbumAuthorizationStatus:(CheckBlock)isAgree {
    [CheckAuthorization requestAlbumAuthorizationStatus:^(BOOL result) {
        isAgree(result);
    }];
}

+ (void)requestAlbumAuthorizationStatus:(CheckBlock)isAgree {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        isAgree(status == PHAuthorizationStatusAuthorized);
    }];
}

#pragma mark - < camera >
+ (void)checkCameraAuthorizationStatus:(CheckBlock)isAgree {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        isAgree(true);
    }else {
        [CheckAuthorization requestCameraAuthorizationStatus:^(BOOL result) {
            isAgree(result);
        }];
    }
}

+ (void)requestCameraAuthorizationStatus:(CheckBlock)isAgree {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        isAgree(granted);
    }];
}

#pragma mark - < microphone >
+ (void)checkMicrophoneAuthorizationStatus:(CheckBlock)isAgree {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusAuthorized) {
        isAgree(true);
    }else {
        [CheckAuthorization requestMicrophoneAuthorizationStatus:^(BOOL result) {
            isAgree(result);
        }];
    }
}

+ (void)requestMicrophoneAuthorizationStatus:(CheckBlock)isAgree {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        isAgree(granted);
    }];
}

@end
