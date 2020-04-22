//
//  UIView+Extension.swift
//  MemoryKing
//
//  Created by ming on 2019/9/15.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

//https://blog.csdn.net/allanGold/article/details/57083070
//AutoLayout的适配是在调用N次（子控件个数）控制器的viewDidLayoutSubviews:方法后才完成的，在stackoverflow上也有人建议在此方法中做操作。但是如果像是自定义的cell这么去做，肯定不方便，再者关键是viewDidLayoutSubviews:会调用多次，会影响用户体验和性能。

extension UIView {
    @objc public func refreshConstraintsImmediately() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

extension UIView {
    public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var newFrame = frame
            newFrame.origin.x = newValue;
            frame = newFrame;
        }
    }
    
    public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var newFrame = frame
            newFrame.origin.y = newValue;
            frame = newFrame;
        }
    }
    
    public var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            var newCenter = center
            newCenter.x = newValue
            center = newCenter
        }
    }
    
    public var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            var newCenter = center
            newCenter.y = newValue
            center = newCenter
        }
    }
    
    public var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var newFrame = frame
            newFrame.origin.x = newValue - frame.size.width;
            frame = newFrame;
        }
    }
    
    public var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var newFrame = frame
            newFrame.origin.y = newValue - frame.size.height;
            frame = newFrame;
        }
    }
    
    public var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            var newFrame = frame
            newFrame.origin = newValue;
            frame = newFrame;
        }
    }
    
    public var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            var newFrame = frame
            newFrame.size.width = newValue;
            frame = newFrame;
        }
    }
    
    public var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            var newFrame = frame
            newFrame.size.height = newValue;
            frame = newFrame;
        }
    }
    
    public var size: CGSize {
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
