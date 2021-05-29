//
//  InternalTogglesDataSource.swift
//  Moments
//
//  Created by Jake Lin on 31/10/20.
//

import Foundation

enum InternalToggle: String, ToggleType {
    case isLikeButtonForMomentEnabled
}

struct InternalTogglesDataStore: TogglesDataStoreType {
    private let userDefaults: UserDefaults

    /**
     当使用NSUserDefaults的的生成的单例对象通过按键在沙盒中获取数据时，
     如果获取不到，则返回空，在某些时刻，就算该键的值不存在，也想返回默认的值，
     那么就可以使用registerDefaults。
     当使用registerDefaults的时候，系统并不会将默认值存储到硬盘中
     
     所以当应用程序启动时就要调用一次registerDefaults，
     故一般注册将该写代码在application:didFinishLaunchingWithOptions中.
     */
    private init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.userDefaults.register(defaults: [
            InternalToggle.isLikeButtonForMomentEnabled.rawValue: false
            ])
    }

    static let shared: InternalTogglesDataStore = .init(userDefaults: .standard)

    func isToggleOn(_ toggle: ToggleType) -> Bool {
        guard let toggle = toggle as? InternalToggle else {
            return false
        }

        return userDefaults.bool(forKey: toggle.rawValue)
    }

    func update(toggle: ToggleType, value: Bool) {
        guard let toggle = toggle as? InternalToggle else {
            return
        }

        userDefaults.set(value, forKey: toggle.rawValue)
    }
}
