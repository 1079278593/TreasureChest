//
//  ResidentScrollViewCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "ResidentScrollViewCtl.h"
#import <Masonry/Masonry.h>
#import "ResidentScrollView.h"

@interface ResidentScrollViewCtl ()<UITableViewDelegate,UITableViewDataSource>

@property(strong, nonatomic)UIView *headerView;
@property(strong, nonatomic)UITableView *tableView;
@property(strong, nonatomic)ResidentScrollView *scrollView;

@end

@implementation ResidentScrollViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, 0);
    self.headerView.frame = CGRectMake(0, 0, KScreenWidth, 300);
    
    _scrollView = [[ResidentScrollView alloc]initWithFrame:CGRectMake(0, 64+10, KScreenWidth, KScreenHeight-64)];
    _scrollView.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.3];
    [self.view addSubview:_scrollView];
    [_scrollView showResident:self.tableView headerView:self.headerView residentHeight:130];
    
    
}

#pragma mark - table
/********************** tableview ****************************/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;//3行
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentify = [NSString stringWithFormat:@"cellIdentify"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.3];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}
/********************** tableview ****************************/

#pragma mark - getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        [self.view addSubview:_tableView];
        
    }
    return _tableView;
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc]init];
//        [self.view addSubview:_headerView];
    }
    return _headerView;
}

@end

