//
//  BaseViewController.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - < public > 待优化
- (void)showNaviViewBackButton {
    [self backButton];
}

- (void)showNaviViewWithTitle:(NSString *)title {
    [self backButton];
    self.titleLabel.text = title;
}

- (void)showNaviViewWithTitle:(NSString *)title rightBtnTitle:(NSString *)rightTitle {
    [self backButton];
    self.titleLabel.text = title;
    [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
}

- (void)showNaviViewWithTitle:(NSString *)title rightBtnImg:(NSString *)rightImg {
    [self backButton];
    self.titleLabel.text = title;
    
    self.rightButton.hidden = false;
    [self.rightButton setTitle:@"" forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:rightImg] forState:UIControlStateNormal];
}

#pragma mark - < event >
- (void)backButtonEvent:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonEvent:(UIButton *)button {
    
}


#pragma mark - < init view >
- (void)setupSubviews {
//    [self initNaviView];
}

- (void)initNaviView {
    
}

- (UIView *)naviView {
    if (_naviView == nil) {
        _naviView = [[UIView alloc]init];
        _naviView.userInteractionEnabled = false;
        _naviView.frame = CGRectMake(0, 20, KScreenWidth, 44);
        [self.view addSubview:_naviView];
    }
    return _naviView;
}

- (UIView *)noDataView {
    if (_noDataView == nil) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 80, KScreenWidth, KScreenHeight-80)];
        _noDataView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_noDataView];
        
        UIImageView *noDataImgView = [[UIImageView alloc]init];
//        noDataImgView.image = [UIImage imageNamed:IMAGE_NO_DATA];
        noDataImgView.contentMode = UIViewContentModeScaleAspectFill;
        [_noDataView addSubview:noDataImgView];
        [noDataImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_noDataView);
            make.width.height.equalTo(@120);
        }];
        
        UILabel *noDataLabel = [[UILabel alloc]init];
        noDataLabel.font = [UIFont systemFontOfSize:14];
        noDataLabel.textColor = [UIColor blackColor];
        noDataLabel.text = @"暂无数据";
        [_noDataView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(noDataImgView.mas_bottom).offset(10);
            make.width.left.equalTo(_noDataView);
            make.height.equalTo(@(20));
        }];
    }
    return _noDataView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor hexColor:@"#080808"];
        [self.view addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.height.equalTo(self.naviView);
            make.width.equalTo(@130);
        }];
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_backButton setImage:[UIImage imageNamed:@"blackBack"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.naviView).offset(14);
            make.top.bottom.equalTo(self.naviView);
            make.width.equalTo(@80);
        }];
    }
    return _backButton;
}

- (UIButton *)rightButton {
    if (_rightButton == nil) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_rightButton setTitle:@"右按钮" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_rightButton];
        CGFloat width = 50;
        CGFloat height = 26;
        _rightButton.frame = CGRectMake(KScreenWidth - 50 -14, 0, width, height);
        _rightButton.centerY = self.naviView.centerY;
    }
    return _rightButton;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor hexColor:@"#DADADA"];
        [self.naviView addSubview:_lineView];
        _lineView.frame = CGRectMake(0, self.naviView.height, self.naviView.width, 0.4);
    }
    return _lineView;
}

@end
