//
//  CollapsibleView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "CollapsibleView.h"
#import "CollapsibleViewCell.h"
#import "CollapsibleViewModel.h"

static NSString *LTMenuItemId = @"LTMenuItemCell";

@interface CollapsibleView()

/** 菜单项 */
@property (nonatomic, strong) NSMutableArray<CollapsibleViewModel *> *menuItems;

/** 当前需要展示的数据 */
@property (nonatomic, strong) NSMutableArray<CollapsibleViewModel *> *latestShowMenuItems;

/** 以前需要展示的数据 */
@property (nonatomic, strong) NSMutableArray<CollapsibleViewModel *> *oldShowMenuItems;

/** 已经选中的选项, 用于回调 */
@property (nonatomic, strong) NSMutableArray<CollapsibleViewModel *> *selectedMenuItems;

/** 全选按钮 */
@property (nonatomic, strong) UIButton *allBtn;

@end

@implementation CollapsibleView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
    }
    return self;
}

- (void)initView {
//    self.title = @"多级菜单";
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"a" ofType:@"plist"];
//    NSArray *date = [NSArray arrayWithContentsOfFile:filePath];
//    
////    self.menuItems = [CollapsibleViewModel mj_objectArrayWithKeyValuesArray:date];
//    
//    UIButton *allBtn = [[UIButton alloc] init];
//    [allBtn setTitle:@"全选" forState:(UIControlStateNormal)];
//    [allBtn setTitle:@"反选" forState:(UIControlStateSelected)];
//    [allBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
//    [allBtn sizeToFit];
//    allBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [allBtn addTarget:self action:@selector(allBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
//    self.allBtn = allBtn;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:allBtn];
//    
//    
//    UIButton *btn = [[UIButton alloc] init];
//    [btn setTitle:@"打印已选" forState:(UIControlStateNormal)];
//    [btn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
//    [btn sizeToFit];
//    btn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [btn addTarget:self action:@selector(printSelectedMenuItems:) forControlEvents:(UIControlEventTouchUpInside)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    
//    // 初始化需要展示的数据
//    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
//    self.tableView.rowHeight = 45;
//    [self.tableView registerClass:[LTMenuItemCell class] forCellReuseIdentifier:LTMenuItemId];
}

#pragma mark - getter and setter
- (NSMutableArray<CollapsibleViewModel *> *)latestShowMenuItems
{
    if (!_latestShowMenuItems) {
        self.latestShowMenuItems = [[NSMutableArray alloc] init];
    }
    return _latestShowMenuItems;
}

- (NSMutableArray<CollapsibleViewModel *> *)selectedMenuItems
{
    if (!_selectedMenuItems) {
        self.selectedMenuItems = [[NSMutableArray alloc] init];
    }
    return _selectedMenuItems;
}

@end
