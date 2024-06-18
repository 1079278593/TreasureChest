//
//  ControllerTableView.m
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import "ControllerTableView.h"
#import "ControllersModel.h"

@interface ControllerTableView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray <ControllersModel *> *datas;

@end

@implementation ControllerTableView

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubViews];
    }
    return self;
}

#pragma mark - < public >
- (void)showWithTabType:(TabType)type {
    NSString *path = [self getPathWithType:type];
    self.datas = [ControllersModel mj_objectArrayWithFile:path];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - < table delegate >
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
    [self.viewController.navigationController pushViewController:controller animated:true];
}

#pragma mark - < private >
- (NSString *)getPathWithType:(TabType)type {
    NSString *fileName = @"Controllers_tab1";
    switch (type) {
        case TabType_first:
            fileName = @"Controllers_tab1";
            break;
        case TabType_second:
            fileName = @"Controllers_tab2";
            break;
        case TabType_third:
            fileName = @"Controllers_tab3";
            break;
        default:
            break;
    }
    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"plist"];
    return path;
}

#pragma mark - < init view >
- (void)setupSubViews {
    [self tableView];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
