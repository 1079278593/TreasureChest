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
#import "ReactiveObjC.h"

static NSString *CellIdentify = @"CellIdentify";

@interface CollapsibleView()<UITableViewDelegate,UITableViewDataSource>

/** 菜单项 */
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *menuItems;

/** 当前需要展示的数据 */
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *latestShowMenuItems;

/** 以前需要展示的数据 */
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *oldShowMenuItems;

/** 已经选中的选项, 用于回调 */
@property (nonatomic, strong) NSMutableArray<CollapsibleModel *> *selectedMenuItems;

/** 全选按钮 */
@property (nonatomic, strong) UIButton *allBtn;

@property(strong, nonatomic)UITableView *tableView;
@property(strong, nonatomic)CollapsibleViewModel *viewModel;

@end

@implementation CollapsibleView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
        [self bindModel];
    }
    return self;
}

- (void)bindModel {
    _viewModel = [[CollapsibleViewModel alloc]init];
    
    @weakify(self);
    [[RACObserve(self.viewModel, datas) ignore:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)initView {
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tableView.rowHeight = 45;
    [self.tableView registerClass:[CollapsibleViewCell class] forCellReuseIdentifier:CellIdentify];
    _tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    [self addSubview:_tableView];
}

#pragma mark - tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_viewModel.datas count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentify = @"cellIdentify";
    CollapsibleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if(!cell){
        cell = [[CollapsibleViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setMenuItem:_viewModel.datas[indexPath.row]];
//    cell.textLabel.text = @"3424";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark - select refresh
#pragma mark - < 添加可以展示的选项 >

- (void)setupRowCount
{
    // 清空当前所有展示项
    [self.latestShowMenuItems removeAllObjects];
    
    // 重新添加需要展示项, 并设置层级, 初始化0
    [self setupRouCountWithMenuItems:self.menuItems index:0];
}

/**
 将需要展示的选项添加到latestShowMenuItems中, 此方法使用递归添加所有需要展示的层级到latestShowMenuItems中

 @param menuItems 需要添加到latestShowMenuItems中的数据
 @param index 层级, 即当前添加的数据属于第几层
 */
- (void)setupRouCountWithMenuItems:(NSArray<CollapsibleModel *> *)menuItems index:(NSInteger)index
{
    for (int i = 0; i < menuItems.count; i++) {
        CollapsibleModel *item = menuItems[i];
        // 设置层级
        item.index = index;
        // 将选项添加到数组中
        [self.latestShowMenuItems addObject:item];
        // 判断该选项的是否能展开, 并且已经需要展开
        if (item.isCanUnfold && item.isUnfold) {
            // 当需要展开子集的时候, 添加子集到数组, 并设置子集层级
            [self setupRouCountWithMenuItems:item.subs index:index + 1];
        }
    }
}

#pragma mark - getter and setter
- (NSMutableArray<CollapsibleModel *> *)latestShowMenuItems
{
    if (!_latestShowMenuItems) {
        self.latestShowMenuItems = [[NSMutableArray alloc] init];
    }
    return _latestShowMenuItems;
}

- (NSMutableArray<CollapsibleModel *> *)selectedMenuItems
{
    if (!_selectedMenuItems) {
        self.selectedMenuItems = [[NSMutableArray alloc] init];
    }
    return _selectedMenuItems;
}

@end
