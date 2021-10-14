//
//  RotationViewVertices.swift
//  MemoryKing
//
//  Created by ming on 2019/5/4.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

class RotationViewVertices: NSObject {

}

public enum VerticeLocation {
    case UpLeft         //左上角
    case UpRight        //右上角
    case DownLeft       //左下角
    case DownRight      //右下角
}

func getVerticesLocation(location:VerticeLocation,view:UIView) -> CGPoint {
    
    let transform = view.transform              //传入的原始transform
    let angle: CGFloat = 0//view.transform.angle_360()      //旋转角度
    
    let noAngleTransform = view.transform.rotated(by: -angle/180.0 * CGFloat.pi)
    view.transform = noAngleTransform
    
    //观察旋转成0度后，frame是正确
    let noAngleView = UIView()
    noAngleView.layer.borderWidth = 1
    noAngleView.layer.borderColor = UIColor.red.cgColor
    noAngleView.transform = view.transform
    noAngleView.frame = view.frame
    
    //改回原来的transform
    view.transform = transform
    
    //计算
    let point = getVerticesLocation(location: location, viewFrame: noAngleView.frame, angle: angle)
    
    return point
}

//viewFrame是未旋转的frame
private func getVerticesLocation(location:VerticeLocation, viewFrame:CGRect, angle:CGFloat) -> CGPoint {
    
    let size = viewFrame.size
    let viewCenter = CGPoint(x: viewFrame.midX, y: viewFrame.midY)
    
    //半径
    let radius = sqrt(pow(size.width, 2)+pow(size.height, 2)) / 2.0
    
    //夹角为：tanA = 高/宽
    let frameAngle = atan(size.height/size.width) / CGFloat.pi * 180
    
    //转为弧度
    var radian:CGFloat = 0.0
    
    switch location {
    case .UpLeft:
        radian = (angle + frameAngle) / 180 * CGFloat.pi
    case .UpRight:
        radian = (angle + frameAngle + (180.0 - frameAngle*2.0)) / 180 * CGFloat.pi
    case .DownLeft:
        radian = (angle - frameAngle) / 180 * CGFloat.pi
    case .DownRight:
        radian = (angle + frameAngle + 180) / 180 * CGFloat.pi
    }
    
    let pointX = viewCenter.x - radius*cos(radian)
    let pointY = viewCenter.y - radius*sin(radian)
    return CGPoint(x: pointX, y: pointY)
}
