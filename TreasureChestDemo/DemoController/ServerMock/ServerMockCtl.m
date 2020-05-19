//
//  ServerMockCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "ServerMockCtl.h"

@interface ServerMockCtl ()

@end

@implementation ServerMockCtl

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.image = [UIImage imageNamed:@"bgPic"];
    imgView.frame = self.view.frame;
    [self.view addSubview:imgView];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
//    self.navigationController.navigationBarHidden = true;
}

- (void)initView {
    
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showButton setTitle:@"按钮" forState:UIControlStateNormal];
    [showButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(showBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showButton];
    [showButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(@50);
    }];
}

- (void)showBtnEvent:(UIButton *)button {
    [EasyProgress showMessage:@"待完善"];
}

@end
