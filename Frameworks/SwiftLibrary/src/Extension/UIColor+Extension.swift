//
//  UIColor+Extension.swift
//  Swift-Extension
//
//  Created by ming on 2019/8/8.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public extension UIColor {

    class func hexColor(_ hexString:String, _ alpha: CGFloat = 1) -> UIColor {
        var cstr = hexString.trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines).uppercased() as NSString
        if(cstr.length < 6){
            return UIColor.clear;
        }
        if(cstr.hasPrefix("0X")){
            cstr = cstr.substring(from: 2) as NSString
        }
        if(cstr.hasPrefix("#")){
            cstr = cstr.substring(from: 1) as NSString
        }
        if(cstr.length != 6){
            return UIColor.clear;
        }
        var range = NSRange.init()
        range.location = 0
        range.length = 2
        //r
        let rStr = cstr.substring(with: range);
        //g
        range.location = 2;
        let gStr = cstr.substring(with: range)
        //b
        range.location = 4;
        let bStr = cstr.substring(with: range)
        var r :UInt32 = 0x0;
        var g :UInt32 = 0x0;
        var b :UInt32 = 0x0;
        Scanner.init(string: rStr).scanHexInt32(&r);
        Scanner.init(string: gStr).scanHexInt32(&g);
        Scanner.init(string: bStr).scanHexInt32(&b);
        return UIColor.init(CGFloat(r), CGFloat(g), CGFloat(b), alpha)
    }
    
    /// RGB颜色，便利构造方法
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) {
        self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    convenience init(_ RGB: CGFloat, _ alpha: CGFloat = 1.0) {
        self.init(red: RGB/255.0, green: RGB/255.0, blue: RGB/255.0, alpha: alpha)
    }
}
