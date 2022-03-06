//
//  EffectARealityModel.h
//  Poppy_Dev01
//
//  Created by ming on 2021/1/17.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "BaseModel.h"
#import "EffectsConfig.h"
#import "EffectFaceMaskModel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - < 装饰 >
@interface EffectARDecorate : BaseModel
@property(nonatomic, assign)BOOL canUse;                //!< 是否可以使用
@property(nonatomic, strong)NSNumber *Id;               //!< 主键
@property(nonatomic, strong)NSString *name;             //!< 名字
@property(nonatomic, strong)NSString *picture;          //!< 图片
@property(nonatomic, strong)NSString *thumbnail;        //!< 缩略图
@property(nonatomic, strong)NSString *url;              //!< 动效链接

@property(nonatomic, strong)NSString *type;             //!< 类型（lottie：lottie
//待增加对应枚举，

@end


#pragma mark - < LUT >
@interface EffectARLut : BaseModel
@property(nonatomic, assign)BOOL canUse;                //!< 是否可以使用
@property(nonatomic, strong)NSNumber *Id;               //!< 主键
@property(nonatomic, assign)int isAffectPortrait;       //!< 是否作用于人像，0：否，1：是 ,
@property(nonatomic, strong)NSString *name;             //!< 名字
@property(nonatomic, strong)NSString *picture;          //!< 图片（lut图片，其它类型不需要这个字段）
@property(nonatomic, strong)NSString *thumbnail;        //!< 缩略图

//!< 类型（lut：lut，lutGenerate：生成lut，漫画：cartoon，gauss：模糊，bulge：哈哈镜，invert：颠转，pixel：马赛克，sketch：铅笔画(组合两个滤镜的效果)，threshold：边缘（组合滤镜））
@property(nonatomic, strong)NSString *type;

///获取滤镜名称，内部根据type去筛选。可能是组合的滤镜，所以返回数组
- (NSArray *)filterNames;
- (EffectsFilterType)filterType;

@end


#pragma mark - < Scene >
@interface EffectARScene: BaseModel
@property(nonatomic, assign)BOOL canUse;                //!< 是否可以使用
@property(nonatomic, strong)NSNumber *Id;               //!< 主键
@property(nonatomic, strong)NSString *name;             //!< 名字
@property(nonatomic, strong)NSString *picture;          //!< 图片
@property(nonatomic, strong)NSString *thumbnail;        //!< 缩略图
@property(nonatomic, assign)BOOL useExtPoint;           //!< 是否使用扩展点
@property(nonatomic, assign)int frameNumberPerSecond;   //!< 帧率
@property(nonatomic, assign)int row;                    //!< 行
@property(nonatomic, assign)int column;                 //!< 列
@property(nonatomic, assign)CGFloat abscissa;           //!< 横坐标
@property(nonatomic, assign)CGFloat ordinate;           //!< 纵坐标
@property(nonatomic, assign)CGFloat width;              //!< 宽
@property(nonatomic, assign)CGFloat height;             //!< 高

/// 类型（普通：normalScene，动态普通场景：dynamicNormalScene，特殊场景：specialScene，动态特殊场景：dynamicSpecialScene，毛玻璃背景：glassScene）
@property(nonatomic, strong)NSString *type;
@property(nonatomic, assign)EffectsSceneType sceneType;//待：改成方法，因为这个类会被缓存，不改也问题不大。

@end


#pragma mark - < 主model >
@interface EffectARealityModel : BaseModel
@property(nonatomic, assign)NSString *arVersion;        //!< ar版本号
@property(nonatomic, assign)int level;                  //!< 模型的级别 0：小，1：中，2：大
@property(nonatomic, strong)NSMutableArray <EffectFaceMaskModel *> *maskList;   //面具：一级
@property(nonatomic, strong)NSMutableArray <EffectARDecorate *> *decorateList;  //装饰：二级
@property(nonatomic, strong)NSMutableArray <EffectARLut *> *lutList;            //滤镜：二级
@property(nonatomic, strong)NSMutableArray <EffectARScene *> *sceneList;        //场景：二级

//保存>缓存>默认。 ‘缓存’需要实时点击就生效(除了已经保存的那个面具不能变，点击保存才会变化)
@property(nonatomic, strong)NSNumber *saveMaskId;       //!< 非接口字段：保存的一级ID。（用户点击保存按钮后才会有值）
@property(nonatomic, strong)NSNumber *saveSceneId;      //!< 二级ID，依托于一级ID。
@property(nonatomic, strong)NSNumber *saveLutId;        //!< 二级ID，依托于一级ID。如果一级ID等于saveMaskId，则直接取这里的值，否则在具体EffectFaceMaskModel内取。
@property(nonatomic, strong)NSNumber *saveDecorateId;   //!< 二级ID，依托于一级ID。

//无须_selectedSceneId;_selectedLutId;_selectedDecorateId;这样的子级，直接赋值到EffectFaceMaskModel类的各个cacheId中，
@property(nonatomic, strong)NSNumber *selectedMaskId;   //!< 非接口字段：用户当前点击选中的。1.内部有get方法；2.每次启动要重置。重置在方法内dataPreprocessing()处理

- (void)dataPreprocessing;                              //!< 这里要做一下初始预处理，加载数据时一定要调用。

- (EffectFaceMaskModel *)getSelectedFaceMask;           //!< 获取当前选中的面具。
- (EffectFaceMaskModel *)getSavedFaceMask;              //!< 获取’保存‘的面具。
- (long)getSelectedIdWithType:(EffectsPickerType)type;  //!< 获取选中的index：保存>缓存>默认

- (EffectFaceMaskModel *)getFaceMaskModelWithMaskId:(long)maskId;
- (EffectARScene *)getSceneModelWithId:(long)sceneId;
- (EffectARLut *)getFilterModelWithId:(long)filterId;
- (EffectARDecorate *)getDecorateModelWithId:(long)decorateId;

@end

NS_ASSUME_NONNULL_END
