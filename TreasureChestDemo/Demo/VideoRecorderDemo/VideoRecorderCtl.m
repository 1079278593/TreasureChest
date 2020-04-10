//
//  VideoRecorderCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/10.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoRecorderCtl.h"
#import "DrawingBoardView.h"

@interface VideoRecorderCtl ()

@property(nonatomic, strong)DrawingBoardView *drawView;
@property(nonatomic, strong)UIButton *startRecordBtn;

@end

@implementation VideoRecorderCtl

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
}

#pragma mark - < event >
- (void)startRecordBtnEvent:(UIButton *)button {
    if (!button.selected) {
        //开始录制
    }else {
        //结束录制
    }
    button.selected = !button.selected;
}

#pragma mark - < init >
- (void)initView {
    
    [self.view addSubview:self.startRecordBtn];
    [self.startRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
        make.width.equalTo(@80);
        make.height.equalTo(@(40));
    }];
    
    self.drawView = [[DrawingBoardView alloc]init];
    self.drawView.layer.borderWidth = 1;
    [self.view addSubview:self.drawView];
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.startRecordBtn.mas_top).offset(-5);
        make.top.equalTo(@64);
    }];
}

- (UIButton *)startRecordBtn {
    if (_startRecordBtn == nil) {
        _startRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startRecordBtn setTitle:@"开始录制" forState:UIControlStateNormal];
        [_startRecordBtn setTitle:@"结束录制" forState:UIControlStateSelected];
        [_startRecordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startRecordBtn addTarget:self action:@selector(startRecordBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        _startRecordBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_startRecordBtn];
        
    }
    return _startRecordBtn;
}
@end
