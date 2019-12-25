//
//  ViewController.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/4.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "ViewController.h"
#import "ResidentScrollViewCtl.h"
#import "CollapsibleViewCtl.h"
#import "TabScrollViewCtl.h"
#import "PearlsPackageCtl.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong, nonatomic)UITableView *tableView;
@property(strong, nonatomic)NSArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.datas = @[@"可驻留的ScrollView",@"可折叠tableView",@"tabScrollView",@"各种小控件：button、label"];
    self.tableView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight);
    
    
}

#pragma mark - table
/********************** tableview ****************************/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentify = [NSString stringWithFormat:@"cellIdentify"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            ResidentScrollViewCtl *controller = [[ResidentScrollViewCtl alloc]init];
            [self.navigationController pushViewController:controller animated:true];
        }
            break;
        case 1:
        {
            CollapsibleViewCtl *controller = [[CollapsibleViewCtl alloc]init];
            [self.navigationController pushViewController:controller animated:true];
        }
            break;
        case 2:
        {
            TabScrollViewCtl *controller = [[TabScrollViewCtl alloc]init];
            [self.navigationController pushViewController:controller animated:true];
        }
            break;
        case 3:
        {
            PearlsPackageCtl *controller = [[PearlsPackageCtl alloc]init];
            [self.navigationController pushViewController:controller animated:true];
        }
            break;
        default:
            break;
    }
}
/********************** tableview ****************************/

#pragma mark - getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
