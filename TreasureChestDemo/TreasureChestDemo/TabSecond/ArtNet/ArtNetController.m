//
//  ArtNetController.m
//  TreasureChest
//
//  Created by imvt on 2022/3/2.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "ArtNetController.h"
#import "artnet.h"
#import "NetworkTool.h"

@interface ArtNetController ()

@end

@implementation ArtNetController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startArtNet];
//    [NetworkTool getIPAddress:YES];
//    [NetworkTool sysGetIpAddresses];
}

- (void)startArtNet {
    NSString *nodeIp = @"192.168.0.101";//WiFi
//    NSString *nodeIp = @"192.168.31.246";//以太网
    const char *ip = [nodeIp UTF8String];
    artnet_node node = artnet_new(ip, 1);//1：打印测试信息
    int flag = artnet_start(node);
    if (flag == 0) {
        NSLog(@"success");
//        while (1) {
            artnet_read(node, 0);
//        }
    }else {
        
    }
}


@end
