//
//  TrainingStepUserDefaults.swift
//  MemoryKing
//
//  Created by ming on 2020/2/19.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

import UIKit
import HandyJSON

fileprivate let TrainingStepUserDefaultsKey = "GlobalUserDefaultsKey"

struct TrainingStepUserDefaults: HandyJSON {
    var currentStep: Int = 0;    //当前的教程位置,初始为0
}

extension TrainingStepUserDefaults {
    
    static var read:TrainingStepUserDefaults {
        let dict = UserDefaults.standard.value(forKey: TrainingStepUserDefaultsKey) as? [String:Any] ?? [:]
        let data = TrainingStepUserDefaults.deserialize(from: dict) ?? TrainingStepUserDefaults()
        return data
    }
    
    public func save() {
        let dict = self.toJSON()
        UserDefaults.standard.set(dict, forKey: TrainingStepUserDefaultsKey)
    }

    static func delete() {
        UserDefaults.standard.removeObject(forKey: TrainingStepUserDefaultsKey)
    }
}

//extension TrainingStepUserDefaults {
//    public func islocking(rootIndex:Int, secondIndex:Int) ->Bool {
//        return self.currentStep < (rootIndex*TrainingStepBase + secondIndex)
//    }
//}
