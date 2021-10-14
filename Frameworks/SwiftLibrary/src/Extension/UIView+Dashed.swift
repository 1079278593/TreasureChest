//
//  UIView+Dashed.swift
//  MemoryKing
//
//  Created by ming on 2019/5/18.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public extension UIView {

    //绘制虚线边框
    func addDashedBorderLayer(_ size: CGSize, color: UIColor, lineWidth: CGFloat){
        let shapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        shapeLayer.bounds = shapeRect
//        shapeLayer.cornerRadius = size.width*0.5
        shapeLayer.position = CGPoint(x: size.width*0.5, y: size.height*0.5)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [3,4]
        let path = UIBezierPath(roundedRect: shapeRect, cornerRadius: size.width*0.5)
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
    }

}

public extension UIImageView {
    //phase参数表示在第一个虚线绘制的时候跳过多少个点
    //let lengths:[CGFloat] = [18,10]             // 绘制 跳过 无限循环
    func fillImageWithDash(color: CGColor, phase: CGFloat = 0, lengths: [CGFloat]) {
        
        UIGraphicsBeginImageContext(frame.size)     //位图上下文绘制区域
        image?.draw(in: bounds)
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setLineCap(CGLineCap.square)
        context.setStrokeColor(color)
        context.setLineWidth(frame.height)
        context.setLineDash(phase: phase, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: frame.width, y: 0))
        context.strokePath()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
    }
}
