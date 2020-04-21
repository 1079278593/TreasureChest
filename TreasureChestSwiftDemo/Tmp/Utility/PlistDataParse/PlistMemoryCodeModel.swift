//
//  PlistMemoryCodeModel.swift
//  MemoryKing
//
//  Created by ming on 2020/3/1.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

import UIKit
import HandyJSON

class PlistMemoryCodeModel: NSObject {
    class func getMemoryCode() -> MemoryCode {
        if let path = Bundle.main.path(forResource: "MemoryCode", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) {
            return MemoryCode.deserialize(from: dict) ?? MemoryCode()
        }
        return MemoryCode()
    }
}

struct MemoryCode: HandyJSON {
    var CharacterInfo_Double:[MemoryCodeDetail] = []
    var CharacterInfo_Single:[MemoryCodeDetail] = []
    var CharacterInfo_Poker:[MemoryCodeDetail] = []
    var CharacterInfo_Children:[MemoryCodeDetail] = []
    
    var BasicCode_NUM:[MemoryCodeDetail] = []
    var BasicCode_Poker_Faces:[MemoryCodeDetail] = []
    var BasicCode_Poker_Suit:[MemoryCodeDetail] = []
}

struct MemoryCodeDetail: HandyJSON {
    var abbr_name = ""
    var face_name = ""
    var abbr_profession = ""
    var abbr_characteristics = ""
    var detail_describe = ""
    var detail_example1 = ""
    var detail_example2 = ""
    var detail_explain = ""
    var detail_webLink = ""
}
