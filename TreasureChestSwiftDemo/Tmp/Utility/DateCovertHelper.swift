//
//  LHDateHelper.swift
//  LHSP
//
//  Created by 小明 on 2019/3/19.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

//注意大写的YYYY和yyyy是不同的，YYYY的这周如果跨年就计入下一年

public func nowTime() -> String {
    let currentDate = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale.current
    let time = formatter.string(from: currentDate)
    return time
}

public func dateFromTimestamp(seconds:Int) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    let date = NSDate.init(timeIntervalSince1970: TimeInterval(seconds))
    return formatter.string(from: date as Date)
}

public func dateFromTimestamp(seconds:Int, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    let date = NSDate.init(timeIntervalSince1970: TimeInterval(seconds))
    return formatter.string(from: date as Date)
}


//////////////////////////////////////
public func dateStringToDate(dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    formatter.locale = Locale.current
    if let date = dateFromUTCdateString(dateString: dateString) {
        return formatter.string(from: date)
    }
    return dateString
}

//2019-03-15T16:00:00.000Z
public func dateFromUTCdateString(dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.locale = Locale.current
    return formatter.date(from: dateString)
}

public func isOneDayEndedCompareWithToday(oneDayString: String) -> Bool{
    let today = Date()
    if let oneDay = dateFromUTCdateString(dateString: oneDayString) {
        let result = oneDay.compare(today)
        if result == .orderedDescending {
            return false
        }
    }
    return true
}
