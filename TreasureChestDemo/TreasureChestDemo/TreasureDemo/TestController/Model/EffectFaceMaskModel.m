//
//  MaskPickerModel.m
//  Poppy_Dev01
//
//  Created by jf on 2020/10/12.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "EffectFaceMaskModel.h"

@implementation FaceTrianglePoint

- (instancetype)initWithModelPoint:(FaceTrianglePoint *)point {
    if(self == [super init]){
        self.x = point.x;
        self.y = point.y;
    }
    return self;
}

- (instancetype)initWithPoint:(CGPoint)point {
    if(self == [super init]){
        self.x = point.x;
        self.y = point.y;
    }
    return self;
}

@end

@implementation FaceTriangleModel

- (void)setPointsWithTexturePoints:(NSArray <FaceTrianglePoint *> *)texturePoints {
    if (texturePoints.count == 3) {
        self.pointA = CGPointMake(texturePoints[0].x, texturePoints[0].y);
        self.pointB = CGPointMake(texturePoints[1].x, texturePoints[1].y);
        self.pointC = CGPointMake(texturePoints[2].x, texturePoints[2].y);
    }
}

@end


@implementation EffectARMaskModel


@end

@interface EffectFaceMaskModel () {
    NSMutableArray <FaceTriangleModel *> *faceTriangles_;
    NSMutableArray <FaceTrianglePoint *> *texturePoints_;
}

@end


@implementation EffectFaceMaskModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"effectId": @"id"};
}//前面是属性名称，后面是后台字段（比如：id、operator）

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"modelDataList" : NSStringFromClass([EffectARMaskModel class]),
    };//前边，是属性数组的名字，后边就是类名
}

#pragma mark - < public >

#pragma mark < 预处理 >
//注意这里，UI制作点时，iOS一定要从0开始。否则会越界。这里做越界处理。
- (void)dataPreprocessing {
    [self texturePoints];
    [self faceTriangles];
    NSUInteger textureCount = self.texturePoints.count;
    for (FaceTriangleModel *model in self.faceTriangles) {
        if (model.indexOfPointA >= textureCount || model.indexOfPointB >= textureCount || model.indexOfPointC >= textureCount) {
            continue;
        }
        [model setPointsWithTexturePoints:@[self.texturePoints[model.indexOfPointA],self.texturePoints[model.indexOfPointB],self.texturePoints[model.indexOfPointC]]];
    }
}

#pragma mark < 属性get >
///类型（普通假面：normalMask，动态假面：dynamicMask，漫画：cartoon，arkit：arkit）
- (EffectMaskType)maskType {
    if ([self.type isEqualToString:@"normalMask"]) {
        return EffectMaskTypeNormal;
    }
    if ([self.type isEqualToString:@"dynamicMask"]) {
        return EffectMaskTypeDynamic;
    }
    if ([self.type isEqualToString:@"cartoon"]) {
        return EffectMaskTypeCartoon;
    }
    if ([self.type isEqualToString:@"arkit"]) {
        return EffectMaskTypeARKit;
    }
    if ([self.type isEqualToString:@"incarnation"]) {
        return EffectMaskTypeMaskImg;
    }
    return EffectMaskTypeNormal;
}

- (int)column {
    if (_column == 0) {
        return 1;
    }
    return _column;
}

#pragma mark < 脸部纹理 >
- (NSMutableArray <FaceTriangleModel *> *)faceTriangles {
    if (faceTriangles_ == nil) {
        faceTriangles_ = [self getFaceTriangles:self.outlineGroup];
    }
    return faceTriangles_;
}

- (NSMutableArray<FaceTrianglePoint *> *)texturePoints {
    if (texturePoints_ == nil) {
        texturePoints_ = [FaceTrianglePoint mj_objectArrayWithKeyValuesArray:self.textureCoordinate];
    }
    return texturePoints_;
}

#pragma mark - < private >
- (NSMutableArray *)getFaceTriangles:(NSString *)outlineGroup {
    NSMutableArray *faceArray = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dict = [outlineGroup mj_JSONObject];
    if ([dict isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)dict;
        for (NSArray *points in array) {
            if (points.count < 3) {
                continue;
            }
            FaceTriangleModel *model = [[FaceTriangleModel alloc]init];
            model.indexOfPointA = [points[0] intValue];
            model.indexOfPointB = [points[1] intValue];
            model.indexOfPointC = [points[2] intValue];
            [faceArray addObject:model];
        }
    }
    return faceArray;
}

@end
