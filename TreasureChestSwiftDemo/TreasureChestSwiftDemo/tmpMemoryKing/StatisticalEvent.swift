//
//  StatisticalEvent.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/5/11.
//  Copyright © 2020 xiao ming. All rights reserved.
//  临时的，为了使得原项目不改动

import UIKit

class StatisticalEvent: NSObject {
    
    private class func event(name: String, attributes:[AnyHashable : Any]? = nil) {
        
        
    }
}

extension StatisticalEvent {
    //软件唤醒统计
    public class func appActiveStatistical() {
    }
    
    //截屏事件
    public class func appScreenshotEventAll() {
    }
    //人物高清图界面：截屏事件
    public class func appScreenshotEventHDPic() {
    }
}

extension StatisticalEvent {

    //购买情况统计
    public class func productPurchase(productName: String, status: String) {
        
    }
}

extension StatisticalEvent {
    
    public class func code_page_numPeople() {
    }
    
    public class func code_page_teaching() {
    }
    
    public class func code_page_teaching_detail(classIndex: String) {
        
    }
    
    public class func code_page_ask_hurryup() {//催更按钮
    }
    
    public class func code_page_aboutus() {
    }
    
    public class func code_page_pathLibrary_detail(title: String, count: String) {
        
    }
    
    public class func code_numPeople_browse_baike(name: String) {
        
    }
    
    public class func code_numPeople_browse() {
        
    }
    
    public class func code_numPeople_bigPic(name: String) {
        
    }
}

extension StatisticalEvent {
    public class func training_page_numTraining() {
    }
    
    public class func training_page_numReplay() {
    }
    
    public class func training_transcript_num(transcript: String) {
    }
}

