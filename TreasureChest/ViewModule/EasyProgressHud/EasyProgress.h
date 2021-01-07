//
//  EasyProgress.h
//  TreasureChest
//
//  Created by xiao ming on 2020/3/30.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface EasyProgress : NSObject

@property(nonatomic, strong)MBProgressHUD *hud;
@property(nonatomic, strong)MBProgressHUD *progressHud;

@property(nonatomic, strong)NSMutableArray<MBProgressHUD*> *huds;
@property(nonatomic, strong)MBProgressHUD *activityHud;//只有需要调用hide()方式关闭的，才会激活(赋值)这个属性。自动隐藏的不赋值这个。

+ (instancetype)shareInstance;


//无法自动隐藏，调用方法：hide()，关闭。
+ (void)showLodingWithMode:(MBProgressHUDMode)mode message:(NSString *)text;
+ (void)showLoading:(NSString *)text;


//自动隐藏
+ (void)showMessage:(NSString *)text;
+ (void)showMessage:(NSString *)text delay:(CGFloat)delay;

+ (void)showSuccess:(NSString *)text;
+ (void)showSuccess:(NSString *)text delay:(CGFloat)delay;
+ (void)showFail:(NSString *)text;
+ (void)showFail:(NSString *)text delay:(CGFloat)delay;
+ (void)showCustomView:(NSString *)text customView:(UIView *)customView delay:(CGFloat)delay;

+ (void)showProgress:(NSString *)cancel;

+ (void)hide;

@end
