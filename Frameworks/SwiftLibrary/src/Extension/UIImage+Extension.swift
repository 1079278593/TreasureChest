//
//  UIImage+Extension.swift
//  MemoryKing
//
//  Created by ming on 2019/8/13.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public extension UIImage {
    class func image(withColor color:UIColor, size:CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        if size.width <= 0, size.height <= 0 {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    //宽高比
    func aspectRatio() -> CGFloat {
        return self.size.width/self.size.height
    }
}

