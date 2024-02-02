//
//  DeviceMacro.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/5.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DeviceMacro_h
#define DeviceMacro_h

#define IsPhoneX KScreenWidth >=375.0f && KScreenHeight >= 812.0f
#define IsIpad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define KScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define KScreenWidth  ([[UIScreen mainScreen] bounds].size.width)

#define KStatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)   //!< 刘海屏44，其它20
#define KStatusBarHeightNormal (20)    //
#define KNaviBarHeight (44)
#define KTopBarSafeHeight KStatusBarHeight + KNaviBarHeight

#define KTabBarHeight (CGFloat)(IsPhoneX ? (49.0 + 34.0) : (49.0))
#define KBottomSafeHeight (CGFloat)(IsPhoneX?(34.0):(0))

//degree
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

//暂时放这
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//‘##’ 在宏的定义中可以起到拼接的作用
#define WeakSelf(type)  __weak typeof(type) weak##type = type;
#define StrongSelf(type)  __strong typeof(type) type = weak##type;



/** 暂时放这
 typedef NS_ENUM(NSInteger, StatusType) {
     StatusTypeNormal = 0, // 正常
     StatusTypeConnecting = 1, // 连接中
     StatusTypeSuccess = 2, // 成功
     StatusTypeFail = 5 // 失败
 };


 const NSString *StatusTypeStringMap[] = {
     [StatusTypeNormal] = @"正常",
     [StatusTypeConnecting] = @"连接中",
     [StatusTypeSuccess] = @"成功",
     [StatusTypeFail] = @"失败"
 };
 
 StatusType type = StatusTypeFail;
 NSLog(@"%@", StatusTypeStringMap[type]); //  NSLog: 失败
 
 */

#endif /* DeviceMacro_h */
