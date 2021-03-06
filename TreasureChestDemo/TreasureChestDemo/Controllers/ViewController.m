//
//  ViewController.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/4.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "ViewController.h"

#import "ControllersModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray <ControllersModel *> *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Controllers" ofType:@"plist"];
    self.datas = [ControllersModel mj_objectArrayWithFile:path];
    self.tableView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight-64);
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
    cell.textLabel.text = self.datas[indexPath.row].classTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self jumpMethod:indexPath.row];
}

- (void)jumpMethod:(NSInteger)index {
    Class NameClass = NSClassFromString(self.datas[index].className);
    UIViewController *controller = [[NameClass alloc]init];
    [self.navigationController pushViewController:controller animated:true];
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
