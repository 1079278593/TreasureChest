//
//  TriangleView.swift
//  MemoryKing
//
//  Created by ming on 2019/9/12.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

public class TriangleView: UIView {

    private lazy var linePath: UIBezierPath = UIBezierPath()
    private lazy var lineShape: CAShapeLayer = CAShapeLayer()
    private lazy var startPoint = CGPoint()
    private lazy var middlePoint = CGPoint()
    private lazy var endPoint = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        linePath = UIBezierPath.init()
        lineShape = CAShapeLayer.init()
        lineShape.lineWidth = 1
        lineShape.lineJoin = .miter // 线条间的样式
        lineShape.lineCap = .square //线结尾样式
        lineShape.strokeColor = UIColor.clear.cgColor // 路径颜色
        lineShape.fillColor = UIColor.hexColor("5a9eee").cgColor // 填充颜色
        lineShape.frame=CGRect(x:0, y:0, width:frame.size.width, height:frame.size.height)
        self.layer.addSublayer(lineShape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadTriangle(start: CGPoint, middle: CGPoint, end: CGPoint) {
        startPoint = start
        middlePoint = middle
        endPoint = end
        self.setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        linePath.removeAllPoints()
        
        linePath.move(to: startPoint)
        linePath.addLine(to: middlePoint)
        linePath.addLine(to: endPoint)
        linePath.close()// 闭合路径
        
        lineShape.path = linePath.cgPath // 获取贝塞尔曲线的路径
    }
}
