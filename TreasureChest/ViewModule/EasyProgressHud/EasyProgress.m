//
//  EasyProgress.m
//  TreasureChest
//
//  Created by xiao ming on 2020/3/30.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "EasyProgress.h"

static EasyProgress *instance = nil;

@interface EasyProgress () <MBProgressHUDDelegate>

@end

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

#pragma mark < MBProgressHUDDelegate >
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.huds removeObject:hud];
}

#pragma mark - < loading >
//无法自动隐藏，调用方法：hide()，关闭。
+ (void)showLoading:(NSString *)text {
    [EasyProgress showLodingWithMode:MBProgressHUDModeIndeterminate message:text];
}

+ (void)showLodingWithMode:(MBProgressHUDMode)mode message:(NSString *)text {
    MBProgressHUD *hud = [[EasyProgress shareInstance] getHud];
    hud.userInteractionEnabled = true;
    hud.mode = mode;
    hud.label.text = text;
    [hud showAnimated:true];
    
    [EasyProgress shareInstance].activityHud = hud;
    [[EasyProgress shareInstance].huds addObject:hud];
}

#pragma mark - < loading auto disappear >
+ (void)showMessage:(NSString *)text {
    [self showMessage:text delay:1.2];
}

+ (void)showMessage:(NSString *)text delay:(CGFloat)delay {
    MBProgressHUD *hud = [[EasyProgress shareInstance] getHud];
    hud.userInteractionEnabled = false;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = text;
    [hud showAnimated:true];
    [hud hideAnimated:true afterDelay:delay];
    
    [[EasyProgress shareInstance].huds addObject:hud];
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
    MBProgressHUD *hud = [[EasyProgress shareInstance] getHud];
    hud.userInteractionEnabled = false;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = text;
    hud.customView = customView;
    [hud showAnimated:true];
    [hud hideAnimated:true afterDelay:delay];
    
    [[EasyProgress shareInstance].huds addObject:hud];
}

+ (void)showProgress:(NSString *)cancel {
    MBProgressHUD *hud = [[EasyProgress shareInstance] getHud];
    hud.userInteractionEnabled = true;
    hud.mode = MBProgressHUDModeDeterminate;
    [hud showAnimated:true];
    [hud.button setTitle:cancel forState:UIControlStateNormal];
    [hud.button addTarget:instance action:@selector(cancelWork:) forControlEvents:UIControlEventTouchUpInside];
    
    [EasyProgress shareInstance].activityHud = hud;
    [[EasyProgress shareInstance].huds addObject:hud];
}

#pragma mark - < hide >
+ (void)hide {
    [[EasyProgress shareInstance].activityHud hideAnimated:true];
    [EasyProgress shareInstance].activityHud = nil;
}

#pragma mark - < download cancel >
- (void)cancelWork:(UIButton *)button {
    [EasyProgress hide];
}

- (MBProgressHUD *)getHud {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.delegate = self;
    return hud;
}

@end
