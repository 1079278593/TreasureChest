//
//  CIEColorSpaceModel.m
//  TreasureChest
//
//  Created by imvt on 2022/1/12.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "CIEColorSpaceModel.h"

@implementation CIEPointModel

@end

@implementation PLKRadiationPathModel

@end

@implementation CIEAreaPointModel

@end

@implementation CIEColorSpaceModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"areaPoints" : NSStringFromClass([CIEAreaPointModel class]),
             @"radiationTrajectory" : NSStringFromClass([PLKRadiationPathModel class])
    };//前边，是属性数组的名字，后边就是类名
}

@end
