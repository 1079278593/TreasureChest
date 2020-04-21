//
//  String+Extension.swift
//  MemoryKing
//
//  Created by ming on 2019/9/20.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

extension String {
    func isPureNumber(maxCount: Int = 10) ->Bool {
        let pattern = "^[0-9.]{0,\(maxCount)}"
        let pred = NSPredicate.init(format: "SELF MATCHES %@", pattern)
        let isMatch = pred.evaluate(with: self)
        if self.components(separatedBy: ".").count > 2 {
            return false
        }
        return isMatch
    }
}
