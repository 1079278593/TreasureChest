//
//  EffectARealityModel.m
//  Poppy_Dev01
//
//  Created by ming on 2021/1/17.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "EffectARealityModel.h"

@implementation EffectARDecorate

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"Id": @"id"};
}//前面是属性名称，后面是后台字段（比如：id、operator）

@end

@implementation EffectARLut

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"Id": @"id"};
}//前面是属性名称，后面是后台字段（比如：id、operator）

///获取滤镜名称，内部根据type去筛选。可能是组合的滤镜，所以返回数组
- (NSArray *)filterNames {
    if ([self.type isEqualToString:@"lut"]) {
        return @[@"filterLut"];
    }
    if ([self.type isEqualToString:@"lutGenerate"]) {
        return @[@"filterLutGenerate"];//lut漫画专用
    }
    if ([self.type isEqualToString:@"cartoon"]) {
        return @[@"filterCartoon"];//卡通
    }
    if ([self.type isEqualToString:@"gauss"]) {
        return @[@"filterBlur"];//模糊
    }
    if ([self.type isEqualToString:@"bulge"]) {
        return @[@"filterDistortingMirror"];//哈哈镜
    }
    if ([self.type isEqualToString:@"invert"]) {
        return @[@"filterReverse"];//颠转
    }
    if ([self.type isEqualToString:@"pixel"]) {
        return @[@"filterMasaic"];//马赛克
    }
    if ([self.type isEqualToString:@"sketch"]) {
        return @[@"filterSketch",@"filterGrayscale"];//铅笔画
    }
    if ([self.type isEqualToString:@"threshold"]) {
        return @[@"filterSobelEdge",@"filterGrayscale"];//边缘
    }
    return @[@"universal"];
}

//!< 类型（lut：lut，lutGenerate：生成lut，漫画：cartoon，gauss：模糊，bulge：哈哈镜，invert：颠转，pixel：马赛克，sketch：铅笔画(组合两个滤镜的效果)，threshold：边缘（组合滤镜））
- (EffectsFilterType)filterType {
    if ([self.type isEqualToString:@"lut"]) {
        return EffectsFilterTypeLut;
    }
    if ([self.type isEqualToString:@"lutGenerate"]) {
        return EffectsFilterTypeLutGenerate;
    }
    if ([self.type isEqualToString:@"cartoon"]) {
        return EffectsFilterTypeCartoon;//卡通
    }
    if ([self.type isEqualToString:@"gauss"]) {
        return EffectsFilterTypeBlur;//模糊
    }
    if ([self.type isEqualToString:@"bulge"]) {
        return EffectsFilterTypeDisMirror;//哈哈镜
    }
    if ([self.type isEqualToString:@"invert"]) {
        return EffectsFilterTypeReverse;//颠转
    }
    if ([self.type isEqualToString:@"pixel"]) {
        return EffectsFilterTypeMasaic;//马赛克
    }
    if ([self.type isEqualToString:@"sketch"]) {
        return EffectsFilterTypeSketch;//铅笔画
    }
    if ([self.type isEqualToString:@"threshold"]) {
        return EffectsFilterTypeThreshold;//边缘
    }
    return EffectsFilterTypeNormal;
}

@end

@implementation EffectARScene

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"Id": @"id"};
}//前面是属性名称，后面是后台字段（比如：id、operator）

/// 类型（普通：normalScene，动态普通场景：dynamicNormalScene，特殊场景：specialScene，动态特殊场景：dynamicSpecialScene，毛玻璃背景：glassScene）
- (EffectsSceneType)sceneType {
    if ([self.type isEqualToString:@"normalScene"]) {
        return EffectsSceneTypeNormal;
    }
    if ([self.type isEqualToString:@"dynamicNormalScene"]) {
        return EffectsSceneTypeDynamic;
    }
    if ([self.type isEqualToString:@"specialScene"]) {
        return EffectsSceneTypeSpecial;
    }
    if ([self.type isEqualToString:@"dynamicSpecialScene"]) {
        return EffectsSceneTypeDynamicSpecial;
    }
    if ([self.type isEqualToString:@"glassScene"]) {
        return EffectsSceneTypeGlass;
    }
    return EffectsSceneTypeNormal;
}


@end

@implementation EffectARealityModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"decorateList" : NSStringFromClass([EffectARDecorate class]),
             @"lutList" : NSStringFromClass([EffectARLut class]),
             @"maskList" : NSStringFromClass([EffectFaceMaskModel class]),
             @"sceneList" : NSStringFromClass([EffectARScene class])
    };//前边，是属性数组的名字，后边就是类名
}

#pragma mark - < start and end >
///这里要做一下初始预处理
- (void)dataPreprocessing {
    //重置选中
    _selectedMaskId = 0;
    
    //过滤掉不支持的
    NSMutableArray *newDatas = [NSMutableArray arrayWithCapacity:0];
    for (EffectFaceMaskModel *model in self.maskList) {
        [newDatas addObject:model];
    }
    
    //预处理，纹理和点的处理
    for (EffectFaceMaskModel *model in newDatas) {
        [model dataPreprocessing];
    }
    
    //赋值
    self.maskList = newDatas;
}

#pragma mark - < select >
- (NSNumber *)selectedMaskId {
    if (_selectedMaskId == nil) {
        _selectedMaskId = [self.saveMaskId copy];//如果没有选中，就用saveMaskId（初始时saveMaskId也没有值，外界要判断）
    }
    return _selectedMaskId;
}

//获取选中的faceMaskModel
- (EffectFaceMaskModel *)getSelectedFaceMask {
    return [self getFaceMaskModelWithMaskId:self.selectedMaskId.longValue];
}

- (EffectFaceMaskModel *)getSavedFaceMask {
    return [self getFaceMaskModelWithMaskId:self.saveMaskId.longValue];
}

- (long)getSelectedIdWithType:(EffectsPickerType)type {
    long targetId = 0;
    EffectFaceMaskModel *selectedMaskModel = [self getSelectedFaceMask];
    
    switch (type) {
        case EffectsPickerTypeMask:
            targetId = selectedMaskModel.effectId.longValue;
            break;
        case EffectsPickerTypeFilter:
        {
            targetId = selectedMaskModel.cacheLutId == nil ? selectedMaskModel.defaultLutId.longValue : selectedMaskModel.cacheLutId.longValue;
        }
            break;
        case EffectsPickerTypeDecorate:
        {
            targetId = selectedMaskModel.cacheDecorateId == nil ? selectedMaskModel.defaultDecorateId.longValue : selectedMaskModel.cacheDecorateId.longValue;
        }
            break;
        case EffectsPickerTypeScene:
        {
            targetId = selectedMaskModel.cacheSceneId == nil ? selectedMaskModel.defaultSceneId.longValue : selectedMaskModel.cacheSceneId.longValue;
            
        }
            break;
            
        default:
            break;
    }
    
    return targetId;
}

#pragma mark - < 根据id返回 >
//获取'面具'
- (EffectFaceMaskModel *)getFaceMaskModelWithMaskId:(long)maskId {
    for (EffectFaceMaskModel *model in self.maskList) {
        if (model.effectId.longValue == maskId) {
            return model;
        }
    }
    return self.maskList.firstObject;//返回第一个，如果数组为空，返回空
}

//获取场景
- (EffectARScene *)getSceneModelWithId:(long)sceneId {
    for (EffectARScene *model in self.sceneList) {
        if (model.Id.longValue == sceneId) {
            return model;
        }
    }
    return self.sceneList.firstObject;//返回第一个，如果数组为空，返回空
}

//获取滤镜
- (EffectARLut *)getFilterModelWithId:(long)filterId {
    for (EffectARLut *model in self.lutList) {
        if (model.Id.longValue == filterId) {
            return model;
        }
    }
    return self.lutList.firstObject;//返回第一个，如果数组为空，返回空
}

//获取装饰
- (EffectARDecorate *)getDecorateModelWithId:(long)decorateId {
    for (EffectARDecorate *model in self.decorateList) {
        if (model.Id.longValue == decorateId) {
            return model;
        }
    }
    return self.decorateList.firstObject;//返回第一个，如果数组为空，返回空
}

@end
