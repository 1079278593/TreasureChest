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
    static public let sharedInstance = PlistTrainingStepModel()
    static var rootStep: [TrainingRootStep] {
        get {
            return PlistTrainingStepModel.sharedInstance.getRootStep() ?? [TrainingRootStep]()
        }
    }
    
    private override init() {
        super.init()
    }
    
    ///index = 101、303这种
    class func getTrainingStep(index: Int) -> TrainingStep {
        let rootIndex = index/TrainingStepBase
        let trainingSteps = self.rootStep[rootIndex].trainingStep
        for trainingStep in trainingSteps {
            if trainingStep.index == index {
                return trainingStep
            }
        }
        return TrainingStep()
    }
    
    class func getNextIndex(index: Int) -> Int {
        let rootIndex = index/Int(TrainingStepBase)
        let endIndex = index % TrainingStepBase
        let trainingSteps = self.rootStep[rootIndex].trainingStep
        if endIndex > (trainingSteps.count-1) {
            return (index/Int(TrainingStepBase) + 1) * TrainingStepBase
        }
        return index
    }
    
    private func getRootStep() -> [TrainingRootStep]? {
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
    var cancle = ""     //取消
    var confirm = ""    //确认
    var skip = ""       //跳过
    var describe = ""   //
    var picture = ""    //图片或者gif
    var audio = ""
    var video = ""
    var duration:Float = 0.0    //限制点击，时间到了才能进行下一步。
    var options = [TrainingStepOptions]()
}

struct TrainingStepOptions: HandyJSON {
    var name = ""
    var fileName = ""
    var selected: Bool = false
}
