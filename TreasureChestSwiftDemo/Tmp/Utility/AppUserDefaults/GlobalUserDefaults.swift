//
//  GlobalUserDefaults.swift
//  MemoryKing
//
//  Created by ming on 2019/9/17.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import HandyJSON

fileprivate let GlobalUserDefaultsKey = "GlobalUserDefaultsKey"

struct GlobalUserDefaults: HandyJSON {
    var isCelebrityPortraitPurchased: Bool? //人物原画是否已经购买了
//    var other: String = ""
}

extension GlobalUserDefaults {
    
    static var read:GlobalUserDefaults {
        let dict = UserDefaults.standard.value(forKey: GlobalUserDefaultsKey) as? [String:Any] ?? [:]
        let user = GlobalUserDefaults.deserialize(from: dict) ?? GlobalUserDefaults()
        return user
    }
    
    public func save() {
        let dict = self.toJSON()
        UserDefaults.standard.set(dict, forKey: GlobalUserDefaultsKey)
    }

    static func delete() {
        UserDefaults.standard.removeObject(forKey: GlobalUserDefaultsKey)
    }
}
