//
//  EffectsConfig.h
//  Poppy_Dev01
//
//  Created by jf on 2021/1/30.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#ifndef EffectsConfig_h
#define EffectsConfig_h

/// picker类型
typedef NS_ENUM(NSUInteger, EffectsPickerType) {
    EffectsPickerTypeMask = 0,          //!< 面具
    EffectsPickerTypeFilter,            //!< 滤镜
    EffectsPickerTypeScene,             //!< 场景
    EffectsPickerTypeDecorate,          //!< 装饰
};

///（普通假面：normalMask，动态假面：dynamicMask，漫画：cartoon，arkit：arkit）
typedef NS_ENUM(NSUInteger, EffectMaskType) {
    EffectMaskTypeDefault = 0,          //!< 无面具类型
    EffectMaskTypeNormal,               //!< 普通假面：即将变成原生ARKit
    EffectMaskTypeDynamic,              //!< 动态假面
    EffectMaskTypeCartoon,              //!< 漫画
    EffectMaskTypeARKit,                //!< arkit：arkit实际是unity内部调用的
    EffectMaskTypeMaskImg,              //!< 化身：就是只显示面具
};

/// scene类型（普通：normalScene，动态普通场景：dynamicNormalScene，特殊场景：specialScene，动态特殊场景：dynamicSpecialScene，毛玻璃背景：glassScene）
typedef NS_ENUM(NSUInteger, EffectsSceneType) {
    EffectsSceneTypeNormal = 0,         //!< 普通：静态图
    EffectsSceneTypeDynamic,            //!< 动态：动态图
    EffectsSceneTypeSpecial,            //!< 特殊场景：普通+头像位置固定
    EffectsSceneTypeDynamicSpecial,     //!< 动态特殊：动态场景+头像固定
    EffectsSceneTypeGlass,              //!< 毛玻璃：原图加模糊滤镜
};

/// 类型（lut：lut，lutGenerate：生成lut，漫画：cartoon，gauss：模糊，bulge：哈哈镜，invert：颠转，pixel：马赛克，sketch：铅笔画(组合两个滤镜的效果)，threshold：边缘（组合滤镜））
typedef NS_ENUM(NSUInteger, EffectsFilterType) {
    EffectsFilterTypeNormal = 0,        //!< 普通
    EffectsFilterTypeLut,               //!< lut
    EffectsFilterTypeLutGenerate,       //!< 生成lut
    EffectsFilterTypeCartoon,           //!< 漫画
    EffectsFilterTypeBlur,              //!< 模糊
    EffectsFilterTypeDisMirror,         //!< 哈哈镜
    EffectsFilterTypeReverse,           //!< 颠转
    EffectsFilterTypeMasaic,            //!< 马赛克
    EffectsFilterTypeSketch,            //!< 铅笔画(组合两个滤镜的效果)
    EffectsFilterTypeThreshold,         //!< 边缘（组合滤镜）
};

#endif /* EffectsConfig_h */
