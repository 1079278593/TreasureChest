//
//  UMengManager.swift
//  MemoryKing
//
//  Created by ming on 2020/3/8.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UMengManager: NSObject {
    
    static public let sharedInstance = UMengManager()
    private var launchOptions:[UIApplication.LaunchOptionsKey: Any]!
    private let disposeBag = DisposeBag()
    
    private override init() {
        super.init()
    }
    
    public func initUMeng(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        self.launchOptions = launchOptions
        UMConfigure.setEncryptEnabled(true)
        UMConfigure.initWithAppkey(KUMengKey, channel: nil)
        MobClick.setScenarioType(.E_UM_NORMAL)  //统计类型：普通、游戏
        MobClick.setAutoPageEnabled(true)
        UMConfigure.setLogEnabled(UMengLogOpen)
        
        StatisticalEvent.appActiveStatistical()
        
        
        // Push组件基本功能配置
        let entity = UMessageRegisterEntity()
        entity.types = Int(UMessageAuthorizationOptions.badge.rawValue | UMessageAuthorizationOptions.sound.rawValue | UMessageAuthorizationOptions.alert.rawValue)
        UNUserNotificationCenter.current().delegate = self
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if granted {
                print("友盟初始化成功")
            }else {
                print("友盟初始化失败")
            }
        }
    }
  
}

extension UMengManager:UNUserNotificationCenterDelegate,UIApplicationDelegate {
    //iOS10新增：前台 收到通知 的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification.request.trigger,
            trigger.isKind(of: UNPushNotificationTrigger.self) {
            UMessage.setAutoAlert(false)
            //应用处于前台时的远程推送接受
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        }else {
            //应用处于前台时的本地推送接受
        }
        completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.sound.rawValue | UNNotificationPresentationOptions.badge.rawValue | UNNotificationPresentationOptions.alert.rawValue))
    }

    //iOS10新增：处理后台点击通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let trigger = response.notification.request.trigger,
            trigger.isKind(of: UNPushNotificationTrigger.self) {
            //应用处于后台时的远程推送接受
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        }else {
            //应用处于后台时的本地推送接受
        }
    }

}
