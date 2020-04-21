//
//  PlistTrainingStepModel.swift
//  MemoryKing
//
//  Created by ming on 2020/2/20.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

import UIKit
import HandyJSON

class PlistTrainingStepModel: NSObject {
    
    class func getTrainingStep() -> [TrainingRootStep]? {
        if let path = Bundle.main.path(forResource: "TrainingStep", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) {
            let dictData = try? JSONSerialization.data(withJSONObject: dict, options: [])
            let dictStr = String(data: dictData!, encoding: .utf8)
            return [TrainingRootStep].deserialize(from: dictStr, designatedPath: "allStep") as? [TrainingRootStep]
        }
        return nil
    }
}

struct TrainingRootStep: HandyJSON {
    var title = ""
    var trainingStep:[TrainingStep] = []
}

struct TrainingStep: HandyJSON {
    var title = ""
    var index:Int = 0
    var speaker = ""            //人物名称
    var speakerPortrait = ""    //人物图片imageName
    var stepDetail:[TrainingStepDetail] = []
}

struct TrainingStepDetail: HandyJSON {
    var title = ""
    var cancle = ""
    var confirm = ""
    var describe = ""   //
    var picture = ""    //图片或者gif
    var audio = ""
    var video = ""
    var options = ""    //需要根据"、"分割。比如："葡萄、柠檬、橙子"
    var duration:Float = 0.0    //限制点击，时间到了才能进行下一步。
}
