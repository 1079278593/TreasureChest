//
//  EasyProgress.m
//  TreasureChest
//
//  Created by xiao ming on 2020/3/30.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "EasyProgress.h"

static EasyProgress *instance = nil;

@implementation EasyProgress

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EasyProgress alloc]init];
        instance.huds = [NSMutableArray arrayWithCapacity:0];
    });
    [instance.hud hideAnimated:true];//去掉之前的(考虑是否增加一个数组记录hud,只处理对应的，否则会出现A的hide事件导致B消失了)
    return instance;
}

#pragma mark - < loading >
//无法自动隐藏，调用方法：hide()，关闭。
+ (void)showLoading:(NSString *)text {
    [EasyProgress showLodingWithMode:MBProgressHUDModeIndeterminate message:text];
}

+ (void)showLodingWithMode:(MBProgressHUDMode)mode message:(NSString *)text {
    EasyProgress *progressHud = [EasyProgress shareInstance];
    progressHud.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    progressHud.hud.userInteractionEnabled = true;
    progressHud.hud.mode = mode;
    progressHud.hud.label.text = text;
    [progressHud.hud showAnimated:true];
}

#pragma mark - < loading auto disappear >
+ (void)showMessage:(NSString *)text {
    [self showMessage:text delay:1.2];
}

+ (void)showMessage:(NSString *)text delay:(CGFloat)delay {
    EasyProgress *progressHud = [EasyProgress shareInstance];
    progressHud.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    progressHud.hud.userInteractionEnabled = false;
    progressHud.hud.mode = MBProgressHUDModeIndeterminate;
    progressHud.hud.label.text = text;
    [progressHud.hud showAnimated:true];
    [progressHud.hud hideAnimated:true afterDelay:delay];
}

#pragma mark - < custom view >
+ (void)showSuccess:(NSString *)text {
    [self showSuccess:text delay:1.2];
}

+ (void)showSuccess:(NSString *)text delay:(CGFloat)delay {
    [self showCustomView:text customView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_success"]] delay:delay];
}

+ (void)showFail:(NSString *)text {
    [self showFail:text delay:1.2];
}

+ (void)showFail:(NSString *)text delay:(CGFloat)delay {
    [self showCustomView:text customView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_error"]] delay:delay];
}

//hud_info、hud_error、hud_success
+ (void)showCustomView:(NSString *)text customView:(UIView *)customView delay:(CGFloat)delay {
    EasyProgress *progressHud = [EasyProgress shareInstance];
    progressHud.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    progressHud.hud.userInteractionEnabled = false;
    progressHud.hud.mode = MBProgressHUDModeCustomView;
    progressHud.hud.label.text = text;
    progressHud.hud.customView = customView;
    [progressHud.hud showAnimated:true];
    [progressHud.hud hideAnimated:true afterDelay:delay];
}

+ (void)showProgress:(NSString *)cancel {
    EasyProgress *progressHud = [EasyProgress shareInstance];
    progressHud.progressHud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    progressHud.progressHud.userInteractionEnabled = true;
    progressHud.progressHud.mode = MBProgressHUDModeDeterminate;
    [progressHud.progressHud showAnimated:true];
    [progressHud.progressHud.button setTitle:cancel forState:UIControlStateNormal];
    [progressHud.progressHud.button addTarget:instance action:@selector(cancelWork:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        float progress = 0.0f;
            while (progress < 1.0f) {
        //        if (self.canceled) break;
                progress += 0.01f;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Instead we could have also passed a reference to the HUD
                    // to the HUD to myProgressTask as a method parameter.
                    [MBProgressHUD HUDForView:[UIApplication sharedApplication].keyWindow].progress = progress;
                });
                usleep(50000);
            }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHud.progressHud hideAnimated:YES];
        });
    });
}

#pragma mark - < hide >
+ (void)hide {
    [instance.hud hideAnimated:true];
}

#pragma mark - < download cancel >
- (void)cancelWork:(UIButton *)button {
    这里还要停止动画。
    [[MBProgressHUD HUDForView:[UIApplication sharedApplication].keyWindow] hideAnimated:true];
}

@end
