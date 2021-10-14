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
#import "DeviceMacro.h"

static NSString *CellIdentify = @"CellIdentify";

@interface CollapsibleView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)CollapsibleViewModel *viewModel;

@end

@implementation CollapsibleView

- (instancetype)init {
    if(self == [super init]){
        [self setupSubviews];
        [self bindModel];
    }
    return self;
}

- (void)bindModel {
    _viewModel = [[CollapsibleViewModel alloc]init];
    
    @weakify(self);
    [[RACObserve(self.viewModel, rootItems) ignore:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.viewModel resetVisibleItems];
        [self.tableView reloadData];
    }];
}

- (void)setupSubviews {
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
}

#pragma mark - < table >
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.rowHeight = 45;
        [_tableView registerClass:[CollapsibleViewCell class] forCellReuseIdentifier:CellIdentify];
        [self addSubview:_tableView];
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _viewModel.currentItems.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CollapsibleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentify forIndexPath:indexPath];
    cell.menuItem = _viewModel.currentItems[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CollapsibleModel *menuItem = _viewModel.currentItems[indexPath.row];
    if (!menuItem.isCanUnfold) return;
    menuItem.isUnfold = !menuItem.isUnfold; //设置展开闭合
    
    // 更新被点击cell，这个方法会直接跳转(cellForRowAtIndexPath、以及其他delegate函数)，去更新cell代码。
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    
    [self.viewModel resetVisibleItems];
    
    [self startCellAnimation:indexPath];
}

#pragma mark - < private method >
- (void)startCellAnimation:(NSIndexPath *)indexPath {
    // 判断老数据和新数据的数量, 来进行展开和闭合动画
    // 定义一个数组, 用于存放需要展开闭合的indexPath
    NSMutableArray<NSIndexPath *> *indexPaths = @[].mutableCopy;
    
    // 如果 老数据 比 新数据 多, 那么就需要进行闭合操作
    if (_viewModel.lastedItems.count > _viewModel.currentItems.count) {
        // 遍历lastedItems, 找出多余的老数据对应的indexPath
        for (int i = 0; i < _viewModel.lastedItems.count; i++) {
            // 当新数据中 没有对应的item时
            if (![_viewModel.currentItems containsObject:_viewModel.lastedItems[i]]) {
                NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [indexPaths addObject:subIndexPath];
            }
        }
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationTop)];
    }else {
        // 此时 新数据 比 老数据 多, 进行展开操作
        // 遍历 currentItems, 找出 lastedItems 中没有的选项, 就是需要新增的indexPath
        for (int i = 0; i < _viewModel.currentItems.count; i++) {
            if (![_viewModel.lastedItems containsObject:_viewModel.currentItems[i]]) {
                NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [indexPaths addObject:subIndexPath];
            }
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationTop)];
    }
}

@end
