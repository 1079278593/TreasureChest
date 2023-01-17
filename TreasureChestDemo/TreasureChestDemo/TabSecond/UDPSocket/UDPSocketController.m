//
//  UDPSocketController.m
//  TreasureChest
//
//  Created by imvt on 2022/4/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "UDPSocketController.h"
#import "EasyUDPSocket.h"

@interface UDPSocketController ()

@property(nonatomic, strong)EasyUDPSocket *udpSocket;

@end

@implementation UDPSocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.udpSocket = [[EasyUDPSocket alloc]init];
    [self.udpSocket startWithHost:@"192.169.0.120" BindWithPort:KLightUdpPort];
//    [self.udpSocket startWithHost:@"127.0.0.1" BindWithPort:1024];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    Byte high = KUDPSocketOpcodeHigh;
    Byte low = UDPSocketOpcodeRead & 0xff;
    Byte personality[] = {low,high};

    NSMutableData *resultData = [[NSMutableData alloc]init];
    [resultData appendBytes:personality length:2];
    
    //-----
    
    Byte data[] = {0x01,0x38,0x0f,0x74,0x37,0x71,0x82};
    [resultData appendBytes:data length:7];
    
    //-----
    
    [self.udpSocket sendData:resultData];
}

@end
