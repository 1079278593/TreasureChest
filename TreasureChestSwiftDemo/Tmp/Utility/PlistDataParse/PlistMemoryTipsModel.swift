//
//  PlistMemoryTipsModel.swift
//  MemoryKing
//
//  Created by ming on 2020/3/1.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

import UIKit
import HandyJSON

class PlistMemoryTipsModel: NSObject {
    class func getMemoryTips() -> MemoryTipsModel {
        if let path = Bundle.main.path(forResource: "MemoryTip", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) {
            return MemoryTipsModel.deserialize(from: dict) ?? MemoryTipsModel()
        }
        return MemoryTipsModel()
    }
}

struct MemoryTipsModel: HandyJSON {
    var memoryTips:[String] = []
    var encourages:[MemoryEncouragesModel] = []
}

struct MemoryEncouragesModel: HandyJSON {
    var author = ""
    var quotes = ""
}
