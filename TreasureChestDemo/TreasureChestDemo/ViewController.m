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
#import "FormsViewCtl.h"
#import "ShapeViewCtl.h"
#import "DictionaryMainCtl.h"
#import "VideoPlayerCtl.h"
#import "URLSessionTaskCtl.h"
#import "ServerMockCtl.h"
#import "MBHudDemoViewController.h"
#import "VideoRecorderCtl.h"
#import "LottieAnimationsCtl.h"
#import "LexiconViewCtl.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = [self getCellDatas];
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
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self jumpMethod:indexPath.row];
}

- (void)jumpMethod:(NSInteger)index {
    NSArray *classArrays = [self getClassNames];
    Class NameClass = NSClassFromString(classArrays[index]);
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

- (NSArray *)getCellDatas {
    NSArray *datas = @[@"可驻留的ScrollView",
                       @"可折叠tableView",
                       @"tabScrollView",
                       @"各种小控件：button、label",
                       @"自定义表单",
                       @"各种形状",
                       @"字典、数据库",
                       @"视频播放",
                       @"上传-下载",
                       @"Mock服务端接口",
                       @"HUD效果",
                       @"视频录制-动画转视频",
                       @"lottie资源展示",
                       @"中文词库",
                    ];
    return datas;
}

- (NSArray *)getClassNames {
    NSArray *classArrays = @[NSStringFromClass([ResidentScrollViewCtl class]),
                             NSStringFromClass([CollapsibleViewCtl class]),
                             NSStringFromClass([TabScrollViewCtl class]),
                             NSStringFromClass([PearlsPackageCtl class]),
                             NSStringFromClass([FormsViewCtl class]),
                             NSStringFromClass([ShapeViewCtl class]),
                             NSStringFromClass([DictionaryMainCtl class]),
                             NSStringFromClass([VideoPlayerCtl class]),
                             NSStringFromClass([URLSessionTaskCtl class]),
                             NSStringFromClass([ServerMockCtl class]),
                             NSStringFromClass([MBHudDemoViewController class]),
                             NSStringFromClass([VideoRecorderCtl class]),
                             NSStringFromClass([LottieAnimationsCtl class]),
                             NSStringFromClass([LexiconViewCtl class]),
                            ];
    return classArrays;
}

@end
