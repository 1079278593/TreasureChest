//
//  SecondController.m
//  TreasureChest
//
//  Created by ming on 2021/4/11.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "SecondController.h"
#import "ControllersModel.h"

@interface SecondController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray <ControllersModel *> *datas;

@end

@implementation SecondController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Controllers_tab2" ofType:@"plist"];
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"Controllers_zcam" ofType:@"plist"];
    self.datas = [ControllersModel mj_objectArrayWithFile:path];
    self.tableView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight-64);
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)willResignActiveNotification {
    NSLog(@"myprint: active willResignActiveNotification");
}

- (void)didBecomeActiveNotification {
    NSLog(@"myprint: active didBecomeActiveNotification");
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
    controller.hidesBottomBarWhenPushed = YES;
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
