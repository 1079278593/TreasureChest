//
//  Double+Extension.swift
//  MemoryKing
//
//  Created by ming on 2019/9/20.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public extension Double {
    
    ///四舍五入 到小数点后某一位
    func roundTo(places: Int = 1) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    ///截断 到小数点后某一位
    func truncate(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        let result = Double(Int(self * divisor)) / divisor
        print(result, self)
        return result
    }
}
