//
//  String+Size.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/21.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import UIKit

extension String {
    func stringSize(font:UIFont, size:CGSize) -> CGSize {
        let dic = [NSAttributedString.Key.font:font]
        let strSize = self.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context:nil).size
        return CGSize(width: ceil(strSize.width), height: ceil(strSize.height))
    }
    
    func stringHeight(font:UIFont, width:CGFloat) -> CGFloat {
        let size = CGSize.init(width: width, height:  CGFloat(MAXFLOAT))
        let dic = [NSAttributedString.Key.font:font]
        let strSize = self.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context:nil).size
        return ceil(strSize.height)
    }

    func stringWidth(font:UIFont, height:CGFloat) -> CGFloat {
        let size = CGSize.init(width: CGFloat(MAXFLOAT), height: height)
        let dic = [NSAttributedString.Key.font:font]
        let strSize = self.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context:nil).size
        return ceil(strSize.width)
    }
}

extension NSAttributedString {
    
    /// 根据给定的范围计算宽高，如果计算宽度，则请把宽度设置为最大，计算高度则设置高度为最大
    ///
    /// - Parameters:
    ///   - width: 宽度的最大值
    ///   - height: 高度的最大值
    /// - Returns: 文本的实际size
    func getSize(width: CGFloat,height: CGFloat) -> CGSize {
        let attributed = self
        let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange.init(location: 0, length: attributed.length), nil, rect.size, nil)
        return CGSize.init(width: size.width + 1, height: size.height + 1)
    }
    
    func getImageRunFrame(run: CTRun, lineOringinPoint: CGPoint, offsetX: CGFloat) -> CGRect {
        /// 计算位置 大小
        var runBounds = CGRect.zero
        var h: CGFloat = 0
        var w: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        var asecnt: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        
        
        let cfRange = CFRange.init(location: 0, length: 0)
        
        w = CGFloat(CTRunGetTypographicBounds(run, cfRange, &asecnt, &descent, &leading))
        h = asecnt + descent + leading
        /// 获取具体的文字距离这行原点的距离 || 算尺寸用的
        x = offsetX + lineOringinPoint.x
        /// y
        y = lineOringinPoint.y - descent
        runBounds = CGRect.init(x: x, y: y, width: w, height: h)
        return runBounds
    }
}
