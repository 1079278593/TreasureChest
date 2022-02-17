//
//  CIEColorSpaceModel.h
//  TreasureChest
//
//  Created by imvt on 2022/1/12.
//  Copyright © 2022 xiao ming. All rights reserved.
//  CIE 1931色度图(CIE 1931 Chromaticity Diagram)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIEPointModel : NSObject

@property(nonatomic, strong)NSString *x;
@property(nonatomic, strong)NSString *y;

@property(nonatomic, strong)NSString *u;
@property(nonatomic, strong)NSString *v;

@end

//黑体辐射轨迹
@interface PLKRadiationPathModel : CIEPointModel

@property(nonatomic, strong)NSString *cct;          //!< 色温

@end

@interface CIEAreaPointModel : CIEPointModel

@property(nonatomic, assign)int λ;                  //!< 波长
@property(nonatomic, strong)NSString *z;

@end

/**
 * CIE 1931色度图(CIE 1931 Chromaticity Diagram)
 * x表示红色分量，y表示绿色分量。
 * E点代表白光，它的坐标为(0.33，0.33)；
 * 环绕在颜色空间边沿的颜色是光谱色，边界代表光谱色的最大饱和度，边界上的数字表示光谱色的波长，其轮廓包含所有的感知色调。
 * 所有单色光都位于舌形曲线上，这条曲线就是单色轨迹，曲线旁标注的数字是单色(或称光谱色)光的波长值；
 * 自然界中各种实际颜色都位于这条闭合曲线内；RGB系统中选用的物理三基色在色度图的舌形曲线上。
 */
@interface CIEColorSpaceModel : NSObject

@property(nonatomic, strong)NSMutableArray <CIEAreaPointModel *> *areaPoints;
@property(nonatomic, strong)NSMutableArray <PLKRadiationPathModel *> *radiationTrajectory;

@end

NS_ASSUME_NONNULL_END
