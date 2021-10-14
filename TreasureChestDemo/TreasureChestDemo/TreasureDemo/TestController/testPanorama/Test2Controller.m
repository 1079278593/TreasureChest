//
//  Test2Controller.m
//  TreasureChest
//
//  Created by ming on 2021/8/15.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "Test2Controller.h"

@interface Test2Controller ()

@end

@implementation Test2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - < init >
- (void)setupSubViews {
    CGFloat height = KScreenHeight;
    
    UIImage *upImage = [UIImage imageNamed:@"panorama_up"];
    UIImageView *upImageView = [[UIImageView alloc]init];
    upImageView.image = upImage;
    [self.view addSubview:upImageView];
    upImageView.contentMode = UIViewContentModeScaleAspectFit;
    [upImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.height.equalTo(@(height));
        make.width.equalTo(@(height * (upImage.size.width/upImage.size.height)));
    }];
    
    UIImage *downImage = [UIImage imageNamed:@"panorama_down"];
    UIImageView *downImageView = [[UIImageView alloc]init];
    downImageView.image = downImage;
    [self.view addSubview:downImageView];
    downImageView.contentMode = UIViewContentModeScaleAspectFit;
    [downImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self.view);
        make.height.equalTo(@(height));
        make.width.equalTo(@(height * (downImage.size.width/downImage.size.height)));
    }];
//    downImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
}

@end
