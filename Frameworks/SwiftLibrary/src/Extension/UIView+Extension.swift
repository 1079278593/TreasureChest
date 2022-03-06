//
//  UIView+Extension.swift
//  MemoryKing
//
//  Created by ming on 2019/9/15.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public let KMainScreenSize = UIScreen.main.bounds.size
public let KMainScreenWidth = UIScreen.main.bounds.width
public let KMainScreenHeight = UIScreen.main.bounds.height

public extension UIView {
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var newFrame = frame
            newFrame.origin.x = newValue;
            frame = newFrame;
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var newFrame = frame
            newFrame.origin.y = newValue;
            frame = newFrame;
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            var newCenter = center
            newCenter.x = newValue
            center = newCenter
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            var newCenter = center
            newCenter.y = newValue
            center = newCenter
        }
    }
    
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var newFrame = frame
            newFrame.origin.x = newValue - frame.size.width;
            frame = newFrame;
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var newFrame = frame
            newFrame.origin.y = newValue - frame.size.height;
            frame = newFrame;
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var newFrame = frame
            newFrame.origin = newValue;
            frame = newFrame;
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            var newFrame = frame
            newFrame.size.width = newValue;
            frame = newFrame;
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            var newFrame = frame
            newFrame.size.height = newValue;
            frame = newFrame;
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            var newFrame = frame
            newFrame.size = newValue;
            frame = newFrame;
        }
    }
}
