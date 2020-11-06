//
//  TestController.m
//  TreasureChest
//
//  Created by jf on 2020/11/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestController.h"

@interface TestController ()

@property(nonatomic, strong)UIView *containerViewA;
@property(nonatomic, strong)UIView *viewAsub1View;
@property(nonatomic, strong)UIView *viewAsub2View;

@property(nonatomic, strong)UIView *containerViewB;
@property(nonatomic, strong)UIView *viewBsub1View;

@property(nonatomic, strong)UIButton *button;

@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setTitle:@"切换按钮" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.frame = CGRectMake(220, 120, 90, 44);
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    UIView *targetView = button.selected ? self.containerViewA : self.containerViewB;
    [targetView addSubview:_viewBsub1View];
    
    button.selected = !button.selected;
    
}

#pragma mark - < init view >
- (void)initView {
    
    //-----------containerViewA-----------
    _containerViewA = [[UIView alloc]initWithFrame:CGRectMake(10, 70, 200, 200)];
    _containerViewA.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:_containerViewA];
    
    _viewAsub1View = [[UIView alloc]initWithFrame:CGRectMake(0, 80, 60, 60)];
    _viewAsub1View.layer.borderWidth = 1;
    [_containerViewA addSubview:_viewAsub1View];
    
    _viewAsub2View = [[UIView alloc]initWithFrame:CGRectMake(100, 0, 60, 60)];
    _viewAsub2View.layer.borderWidth = 1;
    [_containerViewA addSubview:_viewAsub2View];
    
    
    //-----------containerViewB-----------
    _containerViewB = [[UIView alloc]initWithFrame:CGRectMake(10, 280, 200, 200)];
    _containerViewB.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:_containerViewB];
    
    
    _viewBsub1View = [[UIView alloc]initWithFrame:CGRectMake(20, 60, 60, 60)];
    _viewBsub1View.layer.borderWidth = 1;
    _viewBsub1View.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    [_containerViewB addSubview:_viewBsub1View];
}

@end
