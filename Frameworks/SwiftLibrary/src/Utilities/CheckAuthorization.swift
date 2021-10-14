//
//  GlobalConfig.swift
//  MemoryKing
//
//  Created by ming on 2019/4/21.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

public struct CheckAuthorization {
    public typealias CheckBlock = (Bool) -> Void
    ///相册权限
    public static func checkAlbumAuthorizationStatus(isAgree:@escaping CheckBlock) {
        if #available(iOS 8.0, *) {
            requestAlbumAuthorizationStatus { (resulut) in
                isAgree(resulut)
            }
        } else {
            if ALAssetsLibrary.authorizationStatus() == ALAuthorizationStatus.authorized {
                isAgree(true)
            } else {
                self.requestAlbumAuthorizationStatus { (resulut) in
                    isAgree(resulut)
                }
            }
        }
    }
    
    static func requestAlbumAuthorizationStatus(isAgree:@escaping CheckBlock) {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                if status == PHAuthorizationStatus.authorized {
                    isAgree(true)
                } else {
                    isAgree(false)
                }
            }
        }
    }
    
    ///相机权限
    public static func checkCameraAuthorizationStatus(isAgree:@escaping CheckBlock) {
        if AVCaptureDevice.authorizationStatus(for: .video) == AVAuthorizationStatus.authorized {
            isAgree(true)
        } else {
            requestCameraAuthorizationStatus { (resulut) in
                isAgree(resulut)
            }
        }
    }
    
    static func requestCameraAuthorizationStatus(isAgree:@escaping CheckBlock) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            DispatchQueue.main.async {
                isAgree(granted)
            }
        }
    }
    
    ///麦克风权限
    public static func checkMicrophoneAuthorizationStatus(isAgree:@escaping CheckBlock) {
        if AVCaptureDevice.authorizationStatus(for: .audio) == AVAuthorizationStatus.authorized {
            isAgree(true)
        } else {
            requestMicrophoneAuthorizationStatus { (resulut) in
                isAgree(resulut)
            }
        }
    }
    
    static func requestMicrophoneAuthorizationStatus(isAgree:@escaping CheckBlock) {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            DispatchQueue.main.async {
                isAgree(granted)
            }
        }
    }
}
