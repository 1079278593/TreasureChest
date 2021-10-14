//
//  VectorOperation.swift
//  MemoryKing
//
//  Created by ming on 2019/5/4.
//  Copyright © 2019 雏虎科技. All rights reserved.
//

import UIKit

class VectorOperation: NSObject {

}

//投影值：向量*cosine
func vectorProjection(vector: CGPoint, cosine:CGFloat) -> CGFloat {
    let vectorOfModulus = vectorModulus(point: vector)
    return vectorOfModulus * cosine
}







// MARK: ------------------------ 基础计算 ------------------------

/*
 
 * 知识点：
 
   系统函数：cos(<#T##x: CGFloat##CGFloat#>)
   传入的值是弧度，比如这样：cos(CGFloat.pi/3.0)。
   这个函数的计算结果为：0.5，等于数学计算：cos(60°)
 
   系统函数：acos(<#T##x: CGFloat##CGFloat#>)
   传入的值是cos计算的结果，值区间一般是：[-1,1]
   比如cos(60°)值是：0.5
   则：acos(0.5) = 1.0471975511965976  ；
   此值是弧度，转为角度即为：60°。（计算方法：1.0471975511965976 / CGFloat.pi * 180.0）
 
 */




//弧度转角度
func radianToAngle(radian: CGFloat) -> CGFloat {
    return radian / CGFloat.pi * 180.0
}



//角度转弧度
func angleToRadian(angle: CGFloat) -> CGFloat {
    return angle / 180.0 * CGFloat.pi
}



//两个点转成向量：位置向量（坐标轴任意一点与原点组成），实际相当于将起点平移到原点。计算方法：终点 - 起点
func vector(startPoint: CGPoint, endPoint: CGPoint) -> CGPoint {
    return CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
}



//两个向量的夹角度数：0~360
func vectorsAngle(vectorA: CGPoint, vectorB: CGPoint) -> CGFloat {
    let radian = vectorsCosine(vectorA: vectorA, vectorB: vectorB)
    let angle = radianToAngle(radian: acos(radian))
    return angle
}



//两个向量的夹角的cos值
func vectorsCosine(vectorA: CGPoint, vectorB: CGPoint) -> CGFloat {
    let dotProduct = vectorA.x * vectorB.x + vectorA.y * vectorB.y       //    a·b
    print(dotProduct)
    let vectorOfModulus = vectorModulus(point: vectorA) * vectorModulus(point: vectorB) //  |a|*|b|
    let cosine = dotProduct / vectorOfModulus
    return cosine
}



//向量的模
func vectorModulus(point: CGPoint) -> CGFloat {
    return sqrt(pow(point.x, 2) + pow(point.y, 2))
}



/* https://blog.csdn.net/tuibianyanzi/article/details/51884501
 * 判断vectorA是否在vectorBenchmark的右侧
   a 叉乘 b (ax * by - ay * bx)
 
   如果 ax * by - ay * bx > 0，则点A在射线vectorBenchmark的左边。
   如果 ax * by - ay * bx = 0，则点A在射线vectorBenchmark上。
   如果 ax * by - ay * bx > 0，则点A在射线vectorBenchmark的右边。
*/
func isVectorRight(vectorA: CGPoint, vectorBenchmark: CGPoint) -> Bool {
    let crossProduct = vectorA.x * vectorBenchmark.y - vectorA.y * vectorBenchmark.x
    if crossProduct >= 0 {
        return false
    }
    return true
}
