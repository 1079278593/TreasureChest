//
//  CollapsibleViewCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "CollapsibleViewCtl.h"
#import "CollapsibleView.h"

@interface CollapsibleViewCtl ()

@property(strong, nonatomic)CollapsibleView *collapsibleView;

@end

@implementation CollapsibleViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    UIButton *allBtn = [[UIButton alloc] init];
    [allBtn setTitle:@"全选" forState:(UIControlStateNormal)];
    [allBtn setTitle:@"反选" forState:(UIControlStateSelected)];
    [allBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [allBtn sizeToFit];
    allBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [allBtn addTarget:self action:@selector(allBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
//    self.allBtn = allBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:allBtn];
    
    
//    UIButton *btn = [[UIButton alloc] init];
//    [btn setTitle:@"打印已选" forState:(UIControlStateNormal)];
//    [btn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
//    [btn sizeToFit];
//    btn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [btn addTarget:self action:@selector(printSelectedMenuItems:) forControlEvents:(UIControlEventTouchUpInside)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    _collapsibleView = [[CollapsibleView alloc]init];
    _collapsibleView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight-64);
    [self.view addSubview:_collapsibleView];
    
}
@end
