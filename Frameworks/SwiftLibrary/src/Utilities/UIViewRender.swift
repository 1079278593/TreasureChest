//
//  UIViewRender.swift
//  TreasureChestSwiftDemo
//
//  Created by xiao ming on 2020/4/22.
//  Copyright © 2020 xiao ming. All rights reserved.
//

import UIKit

func viewImage(view: UIView) ->UIImage {
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(view.size, false, 2)
    let context = UIGraphicsGetCurrentContext()
    view.layer.render(in: context!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}
