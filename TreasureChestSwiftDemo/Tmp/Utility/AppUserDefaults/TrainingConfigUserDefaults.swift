//
//  TrainingConfigUserDefaults.swift
//  MemoryKing
//
//  Created by ming on 2019/9/24.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit
import HandyJSON

fileprivate let TrainingConfigUserDefaultsKey = "TrainingConfigUserDefaultsKey"

enum TrainingType: String {
    case numTraining
    case pokerTraining
}

struct TrainingConfigUserDefaults: HandyJSON {
    var numTraining = TrainingConfigDetail()
    var pokerTraining = TrainingConfigDetail()
}

struct TrainingConfigDetail: HandyJSON {
    var isAutoSwitch = true
    var trainingCount: Double = 0
    var trainingTime: Double = 0
}

extension TrainingConfigUserDefaults {
    
    public static func read() -> TrainingConfigUserDefaults {
        let dict = UserDefaults.standard.value(forKey: TrainingConfigUserDefaultsKey) as? [String:Any] ?? [:]
        let data = TrainingConfigUserDefaults.deserialize(from: dict) ?? TrainingConfigUserDefaults()
        return data
    }
    
    public func save() {
        let dict = self.toJSON()
        UserDefaults.standard.set(dict, forKey: TrainingConfigUserDefaultsKey)
    }
    
    static func delete() {
        UserDefaults.standard.removeObject(forKey: TrainingConfigUserDefaultsKey)
    }
}
