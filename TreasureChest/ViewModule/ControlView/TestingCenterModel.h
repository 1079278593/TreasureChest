//
//  TestingCenterModel.h
//  amonitor
//
//  Created by imvt on 2021/10/14.
//  Copyright © 2021 Imagine Vision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///展示详情的：过渡方式、动作
typedef NS_ENUM(NSUInteger, TestingShowDetailType) {
    TestingShowDetailTypePresent = 0,
    TestingShowDetailTypeAddToWindow = 1,
    TestingShowDetailTypeBeWindow = 2,
    TestingShowDetailTypePush = 3,
    TestingShowDetailTypeShare = 4,         //!< 点击后弹起分享，目前只有一个日志。
};

@interface TestingCenterCellModel : NSObject

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *target;
@property(nonatomic, assign)TestingShowDetailType showType;
@property(nonatomic, assign)BOOL isHideCenter;              //!< 是否隐藏Testing_CenterContoller，当target被展示后。加到window类型的情况才会为：YES。
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat height;                 //!< target是view的情况，需要定义size，默认居中。

@end

@interface TestingCenterModel : NSObject

@property(nonatomic, strong)NSString *sectionTitle;
@property(nonatomic, strong)NSArray <TestingCenterCellModel *> *datas;

//后面可以改用plist来生成数据，这里先代码构造数据。
+ (NSArray <TestingCenterModel *> *)generateDatas;

@end


NS_ASSUME_NONNULL_END
