//
//  StatisticalEvent.swift
//  MemoryKing
//
//  Created by ming on 2019/9/19.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

class StatisticalEvent: NSObject {
    
    private class func event(name: String, attributes:[AnyHashable : Any]? = nil) {
        
        let uuid = QiKeychainItem.uuid()
        var result = attributes
        
        if var tmp = result {
            tmp["uuid"] = uuid
            result = tmp
        }else {
            result = ["uuid":uuid]
        }
        
        MobClick.event(name, attributes: result)
    }
}

extension StatisticalEvent {
    //软件唤醒统计
    public class func appActiveStatistical() {
        StatisticalEvent.event(name: "applicationWillEnterForeground", attributes: nil)
    }
    
    //截屏事件
    public class func appScreenshotEventAll() {
        StatisticalEvent.event(name: "code_numPeople_screenshot_all", attributes: nil)
    }
    //人物高清图界面：截屏事件
    public class func appScreenshotEventHDPic() {
        StatisticalEvent.event(name: "code_numPeople_screenshot_HDPic", attributes: nil)
    }
}

extension StatisticalEvent {

    //购买情况统计
    public class func productPurchase(productName: String, status: String) {
        let uuid = QiKeychainItem.uuid()
        //合并方式
        let purchaseStatus = "\(productName)+\(status)+\(uuid)+\(nowTime())"
        StatisticalEvent.event(name: "celebrityPortrait_buyStatus", attributes: ["purchaseStatus":purchaseStatus])
    }
}

extension StatisticalEvent {
    
    public class func code_page_numPeople() {
        StatisticalEvent.event(name: "code_page_numPeople")
    }
    
    public class func code_page_teaching() {
        StatisticalEvent.event(name: "code_page_teaching")
    }
    
    public class func code_page_aboutus() {
        StatisticalEvent.event(name: "code_page_aboutus")
    }
    
    public class func code_page_pathLibrary_detail(title: String, count: String) {
        let attributes = ["数据表名称_cell数量": title+count]
        StatisticalEvent.event(name: "code_page_pathLibrary_detail", attributes: attributes)
    }
    
    public class func code_numPeople_browse_baike(name: String) {
        let attributes = ["进入百科人物": name]
        StatisticalEvent.event(name: "code_numPeople_browse_baike", attributes: attributes)
    }
    
    public class func code_numPeople_browse() {
        StatisticalEvent.event(name: "code_numPeople_browse")
    }
    
    public class func code_numPeople_bigPic(name: String) {
        let attributes = ["查看名人高清图": name]
        StatisticalEvent.event(name: "code_numPeople_bigPic", attributes: attributes)
    }
}

extension StatisticalEvent {
    public class func training_page_numTraining() {
        StatisticalEvent.event(name: "training_page_numTraining")
    }
    
    public class func training_page_numReplay() {
        StatisticalEvent.event(name: "training_page_numReplay")
    }
    
    public class func training_transcript_num(transcript: String) {
        let attributes = ["数字训练成绩单": transcript]
        StatisticalEvent.event(name: "training_transcript_num", attributes: attributes)
    }
}
