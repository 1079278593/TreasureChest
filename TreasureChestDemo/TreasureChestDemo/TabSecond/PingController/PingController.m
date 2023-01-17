//
//  PingController.m
//  TreasureChest
//
//  Created by imvt on 2022/9/29.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "PingController.h"
#import "SimplePing.h"
#import "MSWeakTimer.h"
#import <RealReachability/PingHelper.h>

@interface PingController () <SimplePingDelegate>

@property(nonatomic, strong)SimplePing *ping;

@property(nonatomic, strong)MSWeakTimer *timer;
@property(nonatomic, assign)NSInteger countDown;

@property(nonatomic, strong)PingHelper *pingHelper;

@end

@implementation PingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *host = @"192.168.9.78";//hostName 参数可以是主机DNS域名,IPv4,IPv6地址的字符串形式.
    
//    [self initReachilablePingWithHost:host];
    [self initSimplePingWithHost:host];
}


#pragma mark - < timer >
- (void)startTimer {
    [self.timer invalidate];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
}

- (void)timerFire {
    [_ping sendPingWithData:nil];
}

#pragma mark - < simple ping >
- (void)initSimplePingWithHost:(NSString *)host {
    _ping = [[SimplePing alloc]initWithHostName:host];
    _ping.delegate = self;
    _ping.addressStyle = SimplePingAddressStyleICMPv4;
    [_ping start];
}

#pragma mark - < reachilable ping >
- (void)initReachilablePingWithHost:(NSString *)host {
    self.pingHelper = [[PingHelper alloc]init];
    self.pingHelper.host = host;
    [self.pingHelper pingWithBlock:^(BOOL isSuccess) {
        NSLog(@"3424");
    }];
}

#pragma mark - < delegate >
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSLog(@"~~~DidStart~~~: %s--- %@", __func__, self);
//    [pinger sendPingWithData:nil];
    [self startTimer];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"~~~DidFail~~~: %s", __func__);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"DidSend---seq:%d, packet:%lu",sequenceNumber,(unsigned long)packet.length);
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    NSLog(@"~~~DidFailSend~~~: %s", __func__);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"~~~DidReceived~~~: %s", __func__);
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    NSLog(@"~~~DidReceived unexpect~~~: %s", __func__);
    NSString *tmp = [[NSString alloc]initWithData:packet encoding:NSUTF8StringEncoding];
    
    tmp = @"342";
}


@end
