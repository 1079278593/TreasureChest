//
//  BaseViewController.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property(nonatomic, strong)UIView *naviView;
@property(nonatomic, strong)UIButton *backButton;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIButton *rightButton;

@property(nonatomic, strong)UIView *lineView;
@property(nonatomic, strong)UIView *noDataView;

///默认：返回+title，右侧按钮
- (void)showNaviViewBackButton;
- (void)showNaviViewWithTitle:(NSString *)title;
- (void)showNaviViewWithTitle:(NSString *)title rightBtnTitle:(NSString *)rightTitle;
- (void)showNaviViewWithTitle:(NSString *)title rightBtnImg:(NSString *)rightImg;

//事件
- (void)backButtonEvent:(UIButton *)button;
- (void)rightButtonEvent:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
