//
//  EffectFaceMaskModel.h
//  Poppy_Dev01
//
//  Created by jf on 2020/10/12.
//  Copyright © 2020 YLQTec. All rights reserved.
//  面具model

#import "BaseModel.h"
#import "EffectsConfig.h"

#pragma mark - < 点 >
@interface FaceTrianglePoint : BaseModel

@property(nonatomic, assign)double x;
@property(nonatomic, assign)double y;

- (instancetype)initWithModelPoint:(FaceTrianglePoint *)point;
- (instancetype)initWithPoint:(CGPoint)point;

@end

@interface FaceTriangleModel : BaseModel

///由人脸75特征点的任意3个index组成的三角形（0~74），比如[2, 23, 53]，
@property(nonatomic, assign)int indexOfPointA;
@property(nonatomic, assign)int indexOfPointB;
@property(nonatomic, assign)int indexOfPointC;


/* Conveniences property */
//点对应的纹理坐标。（动态面具的处理就是改这里的纹理坐标，除以x/col，y/row）
@property(nonatomic, assign)CGPoint pointA;
@property(nonatomic, assign)CGPoint pointB;
@property(nonatomic, assign)CGPoint pointC;

- (void)setPointsWithTexturePoints:(NSArray <FaceTrianglePoint *> *)texturePoints;

@end


#pragma mark - < 面具 算法模型 >
@interface EffectARMaskModel : BaseModel
@property(nonatomic, assign)int level;                                      //!< 模型的级别 0：小，1：中，2：大 ,
@property(nonatomic, strong)NSString *modelType;                            //!< 模型类型,tnn
@property(nonatomic, strong)NSString *modelUrl;                             //!< 模型的下载地址
@property(nonatomic, assign)int modelWidth;                                 //!< 模型的图片宽度
@property(nonatomic, strong)NSString *protoUrl;                             //!< 模型协议的下载地址
@end


#pragma mark - < 主model，待重命名 >
@interface EffectFaceMaskModel : BaseModel

@property(nonatomic, assign)BOOL canUse;                                    //!< 是否可以使用：这个是不显示还是不能点击
@property(nonatomic, strong)NSString *type;                                 //!<  类型（普通假面：normalMask，动态假面：dynamicMask，漫画：cartoon，arkit：arkit）
@property(nonatomic, assign)EffectMaskType maskType;                        //!< 后台返回了字符串，这里改成枚举。

@property(nonatomic, strong)NSNumber *effectId;                             //!< 主键
@property(nonatomic, strong)NSString *name;                                 //!< 名字
@property(nonatomic, strong)NSString *picture;                              //!< 图片
@property(nonatomic, strong)NSString *thumbnail;                            //!< 缩略图
@property(nonatomic, assign)int row;                                        //!< 行
@property(nonatomic, assign)int column;                                     //!< 列  内部get()
@property(nonatomic, assign)int frameNumberPerSecond;                       //!< 帧率

@property(nonatomic, strong)NSMutableArray <EffectARMaskModel *> *modelDataList; //!< 模型数据，只作用于漫画类型的面具。其它不管
@property(nonatomic, strong)NSString *outlineGroup;                         //!< 轮廓分组
@property(nonatomic, strong)NSString *textureCoordinate;                    //!< 纹理坐标

@property(nonatomic, strong)NSMutableArray <NSNumber *> *decorateIdList;    //!< 可用 装饰id，不使用的默认值0。int类型
@property(nonatomic, strong)NSMutableArray <NSNumber *> *lutIdList;         //!< 可用 滤镜id，不使用的默认值0。int类型
@property(nonatomic, strong)NSMutableArray <NSNumber *> *sceneIdList;       //!< 可用 场景id，不使用的默认值0。int类型

//缓存>默认。
//判断缓存是不0，如果是就用默认，如果不是用缓存。问题就是：0有业务属性，代表不使用，这时你就无法判断是业务的不使用，还是本来为0要用缓存。
@property(nonatomic, strong)NSNumber *defaultDecorateId;                    //!< 默认 装饰id，默认值0。默认是0真的很恶心。。。。
@property(nonatomic, strong)NSNumber *defaultLutId;                         //!< 默认 滤镜id，默认值0
@property(nonatomic, strong)NSNumber *defaultSceneId;                       //!< 默认 场景id，默认值0

//用户点击的结果立马转为缓存，不需要多拿一个selectId这样的字段记录。
@property(nonatomic, strong)NSNumber *cacheDecorateId;                      //!< 缓存 装饰id，默认值0
@property(nonatomic, strong)NSNumber *cacheLutId;                           //!< 缓存 滤镜id，默认值0
@property(nonatomic, strong)NSNumber *cacheSceneId;                         //!< 缓存 场景id，默认值0

///接口请求到数据后，这里要做一下预处理
- (void)dataPreprocessing;

/* Conveniences property */
//取点顺序按照脸部：下部分轮廓、左眉毛、右眉毛、左眼、右眼、鼻子、鼻尖、外唇、内唇
- (NSMutableArray <FaceTriangleModel *> *)faceTriangles;                    //!< 脸部三角形（后台下发“脸部三角形”的，组合方式）
- (NSMutableArray <FaceTrianglePoint *> *)texturePoints;                    //!< 按照约定顺序，返回每个点在纹理的[s，t]。（0~75个点）

@end
