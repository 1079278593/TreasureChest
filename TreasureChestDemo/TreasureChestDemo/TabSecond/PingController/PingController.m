//
//  PingController.m
//  TreasureChest
//
//  Created by imvt on 2022/9/29.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "PingController.h"
#import "PingManager.h"
#import "CameraStatusLoop.h"
#import "GCDAsyncSocket.h"

@interface PingController ()

@property(nonatomic, strong)UITextField *textfield;
@property(nonatomic, strong)UIButton *startButton;
@property(nonatomic, strong)UIButton *startIpsButton;

//测试socket已连接，另外创建socket连接相同的IP和port看看会怎么样
@property(nonatomic, strong)UIButton *trySameIpButton;

@property(nonatomic, strong)UIButton *checkReachableBtn;
@property(nonatomic, strong)CameraStatusLoop *statusLoop;

@end

@implementation PingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubViews];
    
    NSString *host = @"192.168.31.231";//hostName 参数可以是主机DNS域名,IPv4,IPv6地址的字符串形式.
//    host = @"localhost";
//    host = @"10.98.32.1";
    self.textfield.text = host;
}

#pragma mark - < event >
- (void)startEvent:(UIButton *)button {
    [[PingManager shareInstance] startWithHost:self.textfield.text];
}

- (void)startIpsEvent:(UIButton *)button {
//    NSMutableSet *ips = [[NSMutableSet alloc] initWithObjects:@"10.98.32.1", @"10.98.33.1", @"localhost", @"192.168.31.231", nil];
//    NSMutableSet *ips = [[NSMutableSet alloc] initWithObjects:@"10.98.32.1", nil];//成功
//    NSMutableSet *ips = [[NSMutableSet alloc] initWithObjects:@"10.98.33.1", nil];
    NSMutableSet *ips = [[NSMutableSet alloc] initWithObjects:@"localhost", nil];
    [[PingManager shareInstance] reachabilitiesFromHosts:ips];
}

- (void)checkReachableBtnEvent:(UIButton *)button {
    [self.statusLoop checkHosts:@[self.textfield.text]];
}

- (void)trySameBtnEvent:(UIButton *)button {
    [self.statusLoop tryConnectedHost:self.textfield.text];
}

#pragma mark - < init view >
- (void)setupSubViews {
    self.textfield = [[UITextField alloc]init];
    self.textfield.frame = CGRectMake(100, 100, 200, 45);
    [self.view addSubview:self.textfield];
    self.textfield.textColor = [UIColor redColor];
    self.textfield.layer.borderWidth = 1;
    self.textfield.layer.borderColor = KRandomColor(0.8).CGColor;
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startButton setTitle:@"startTextfield" forState:UIControlStateNormal];
    _startButton.backgroundColor = [UIColor lightGrayColor];
    _startButton.frame = CGRectMake(100, 170, 120, 45);
    [self.view addSubview:_startButton];
    [_startButton addTarget:self action:@selector(startEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    _startIpsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startIpsButton setTitle:@"start ips" forState:UIControlStateNormal];
    _startIpsButton.backgroundColor = [UIColor lightGrayColor];
    _startIpsButton.frame = CGRectMake(100, 270, 120, 45);
    [self.view addSubview:_startIpsButton];
    [_startIpsButton addTarget:self action:@selector(startIpsEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    _checkReachableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_checkReachableBtn setTitle:@"reachable" forState:UIControlStateNormal];
    _checkReachableBtn.backgroundColor = [UIColor lightGrayColor];
    _checkReachableBtn.frame = CGRectMake(100, 370, 120, 45);
    [self.view addSubview:_checkReachableBtn];
    [_checkReachableBtn addTarget:self action:@selector(checkReachableBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    _trySameIpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_trySameIpButton setTitle:@"->try same" forState:UIControlStateNormal];
    _trySameIpButton.backgroundColor = [UIColor lightGrayColor];
    _trySameIpButton.frame = CGRectMake(260, 370, 120, 45);
    [self.view addSubview:_trySameIpButton];
    [_trySameIpButton addTarget:self action:@selector(trySameBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
}

- (CameraStatusLoop *)statusLoop {
    if (_statusLoop == nil) {
        _statusLoop = [[CameraStatusLoop alloc]init];
    }
    return _statusLoop;
}

@end
