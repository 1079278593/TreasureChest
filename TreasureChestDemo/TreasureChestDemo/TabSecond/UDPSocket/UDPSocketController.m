//
//  UDPSocketController.m
//  TreasureChest
//
//  Created by imvt on 2022/4/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "UDPSocketController.h"
#import "EasyUDPSocket.h"

#define KHostFront @"192.168.31.179" //面前的设备
#define KHostLeft @"192.168.31.254" //左边的设备

@interface UDPSocketController ()

@property(nonatomic, strong)EasyUDPSocket *udpSocket;

@end

@implementation UDPSocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    
    self.udpSocket = [[EasyUDPSocket alloc]init];
    [self.udpSocket startWithHost:@"" BindWithPort:KLightUdpPort];
//    [self.udpSocket startWithHost:@"127.0.0.1" BindWithPort:1024];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableData *data = [self getData:FixturesColorModeHSI udpOpcode:UDPSocketOpcodeWrite];
    [self.udpSocket switchHost:KHostFront sendData:data];
    NSLog(@"发送：%@",data);
}

- (void)writeEvent:(UIButton *)button {
    NSMutableData *data = [self getData:FixturesColorModeCCT udpOpcode:UDPSocketOpcodeWrite];
    [self.udpSocket switchHost:KHostLeft sendData:data];
}

- (void)readEvent:(UIButton *)button {
    NSMutableData *data = [self getData:FixturesColorModeNone udpOpcode:UDPSocketOpcodeRead];
    [self.udpSocket switchHost:KHostFront sendData:data];
    [self.udpSocket switchHost:KHostLeft sendData:data];
}

- (NSMutableData *)getData:(FixturesColorMode)mode udpOpcode:(UDPSocketOpcode)opcode {
    Byte high = KUDPSocketOpcodeHigh;
    Byte low = opcode & 0xff;
    Byte personality[] = {low,high};

    NSMutableData *datas = [[NSMutableData alloc]init];
    [datas appendBytes:personality length:2];
    
    if (opcode == UDPSocketOpcodeWrite) {
        Byte modeByte = mode;
        Byte data[] = {modeByte,0x38,0x0f,0x74,0x37,0x71,0x82};
        [datas appendBytes:data length:7];
    }else {
//        Byte modeByte = mode;
//        Byte data[] = {modeByte};
//        [datas appendBytes:data length:7];
    }
        
    //先占位的4个字节
    NSMutableData *resultData = [[NSMutableData alloc]init];
    Byte sequence[] = KUDPSeqTmp;
    [resultData appendBytes:sequence length:KUDPSeqSize];
    
    //然后：实际的数据
    [resultData appendData:datas];
    
    return resultData;
}

#pragma mark - < init >
- (void)setupSubViews {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderWidth = 1;
    [button setTitle:@"写左边设备" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(writeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(@150);
    }];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.layer.borderWidth = 1;
    [button1 setTitle:@"读取" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(readEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button.mas_bottom).offset(20);
        make.centerX.equalTo(button);
        make.width.height.equalTo(@150);
    }];
}
@end
