//
//  PingManager.m
//  TreasureChest
//
//  Created by imvt on 2024/2/1.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import "PingManager.h"
#import "SimplePing.h"
#import <RealReachability/PingHelper.h>
#import "MSWeakTimer.h"

@interface PingManager ()<SimplePingDelegate>

@property(nonatomic, strong)SimplePing *ping;
@property(nonatomic, strong)PingHelper *pingHelper;

@property(nonatomic, strong)MSWeakTimer *timer;
@property(nonatomic, assign)NSInteger countDown;

@end

@implementation PingManager

static PingManager *manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PingManager alloc]init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone {
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - < public >
- (void)startWithHost:(NSString *)host {
//    [self startPingHelpWithHost:host];
//    return;
    if (host.length == 0) {
        return;
    }
    
    if (_ping) {
        [_ping stop];
        _ping = nil;
        [self.timer invalidate];
        self.timer = nil;
    }
    _ping = [self startSimplePingWithHost:host];
    [_ping start];
    NSLog(@"start ping");
}

- (NSArray *)reachabilitiesFromHosts:(NSSet *)hosts {
    NSMutableArray *reachabilities = [NSMutableArray arrayWithCapacity:0];
    for (NSString *host in hosts) {
        PingHelper *pingHelper = [[PingHelper alloc]init];
        [self startWithPingHelp:pingHelper host:host];
    }
    
    return reachabilities;
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

#pragma mark - < 方式1： simple ping >
- (SimplePing *)startSimplePingWithHost:(NSString *)host {
    SimplePing *ping = [[SimplePing alloc]initWithHostName:host];
    ping.delegate = self;
    ping.addressStyle = SimplePingAddressStyleICMPv4;
    return ping;
}

#pragma mark - < 方式2： reachilable ping >
- (void)startWithPingHelp:(PingHelper *)pingHelper host:(NSString *)host {
    pingHelper.host = host;
    [pingHelper pingWithBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"pingHelper '%@' success",host);
        }else {
            NSLog(@"pingHelper '%@' fail",host);
        }
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
