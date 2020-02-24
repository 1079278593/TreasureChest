//
//  TabScrollViewCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "TabScrollViewCtl.h"
#import "TabScrollView.h"

@interface TabScrollViewCtl ()
@property(nonatomic, strong)TabScrollView *tabScrollView;
@end

@implementation TabScrollViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *tmpView1 = [[UIView alloc]init];
    UIView *tmpView2 = [[UIView alloc]init];
    UIView *tmpView3 = [[UIView alloc]init];
    UIView *tmpView4 = [[UIView alloc]init];
    UIView *tmpView5 = [[UIView alloc]init];
    UIView *tmpView6 = [[UIView alloc]init];
    
    _tabScrollView = [[TabScrollView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64) contents:@[tmpView1,tmpView2,tmpView3,tmpView4,tmpView5,tmpView6] titles:@[@"title1",@"title2",@"title3",@"title4",@"title5",@"title6"]];
    [self.view addSubview:_tabScrollView];
    [_tabScrollView.titleScrollView addViewShadow];
}



@end
