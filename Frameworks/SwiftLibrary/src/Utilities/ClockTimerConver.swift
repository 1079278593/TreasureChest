//
//  ClockTimerConver.swift
//  MemoryKing
//
//  Created by ming on 2019/9/26.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

func secondToClockTime(newSecond: CGFloat) ->String {
    let hour = doubleNumber(num: Int(newSecond / (60 * 60)))
    let minutes = doubleNumber(num: (Int(newSecond) % 3600) / 60)
    let second = doubleNumber(num: Int(newSecond) % 60)
    let milliscond = Int(newSecond.truncatingRemainder(dividingBy: 1) * 10)
    
    
    return "\(hour):\(minutes):\(second).\(milliscond)"
}

func doubleNumber(num: Int) -> String {
    if num < 10 {
        return "0\(num)"
    } else {
        return "\(num)"
    }
}
