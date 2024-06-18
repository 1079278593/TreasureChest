//
//  CameraStatusLoop.m
//  AwesomeCamera
//
//  Created by imvt on 2024/2/2.
//  Copyright © 2024 ImagineVision. All rights reserved.
//

#import "CameraStatusLoop.h"
#import "GCDAsyncSocket.h"

#import "MSWeakTimer.h"
#import "AFNetworking.h"//WiFi变化
#import "NetworkTool.h"

@interface CameraStatusLoop () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket *httpSocket;
@property(nonatomic, strong)GCDAsyncSocket *httpsSocket;
@property(nonatomic, strong)NSMutableArray *sameSockets;//需要持有，不然立马回被断开

@property(nonatomic, strong)MSWeakTimer *timer;
@property(nonatomic, assign)BOOL isUsbAvaliable;

@end

@implementation CameraStatusLoop

- (instancetype)init {
    if (self = [super init]) {
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        //注册Wi-Fi变化通知
        WS(weakSelf)
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSString *ssid = [NetworkTool currentSSID];
            if ([weakSelf.delegate respondsToSelector:@selector(networkChange:)]) {
                [weakSelf.delegate networkChange:ssid];
            }
        }];
        self.sameSockets = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

#pragma mark - < public >
- (void)startLoop {
    [self startTimer];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stopLoop {
    [self.timer invalidate];
    self.timer = nil;
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

///传入所有要尝试的host，内部会尝试80和443，看看哪个host的哪个端口可行
- (void)checkHosts:(NSArray *)hosts {
    //并行还是串行，
    for (NSString *host in hosts) {
        if ([self.httpSocket isConnected]) {
            [self.httpSocket disconnect];
        }
        if ([self.httpsSocket isConnected]) {
            [self.httpsSocket disconnect];
        }
        [self connectWithSocket:self.httpSocket toHost:host port:80];
        [self connectWithSocket:self.httpsSocket toHost:host port:443];
    }
}

//测试多个socket连接相同的host,
- (void)tryConnectedHost:(NSString *)host {
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connectWithSocket:socket toHost:host port:80];
    [self.sameSockets addObject:socket];
}

#pragma mark - < timer >
- (void)startTimer {
    [self.timer invalidate];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
}

- (void)timerFire {
    [self processTmp];
}

- (void)processTmp {
//    if (self.cameraCtrConnected == YES) {
//        return;//如果已连接，就不处理
//    }
    
    //用pingManager得到一个可以ping通的hosts，需要连接时，就从这个hosts里拿（要上锁）
    
}

//原来的connection就是两个函数：disconnect和connection，其中connection就是checkConnection
- (void)myConnect {
    
}

#pragma mark - < connect >
- (void)connectWithSocket:(GCDAsyncSocket *)socket toHost:(NSString *)host port:(NSUInteger)port {
    NSError *error = nil;
    BOOL flag = [socket connectToHost:host onPort:port withTimeout:3 error:&error];
    if (error != nil) {
        NSLog(@"connect to host failed %@", error);
    }
}

#pragma mark - < delegate >
#pragma mark Proxy
- (void)proxyDidConnectedClent {
    self.isUsbAvaliable = YES;
}

- (void)proxyDidDisconnectedClent {
    self.isUsbAvaliable = NO;
}

#pragma mark - < GCDAsyncSocketDelegate >
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"socket connected '%@:%hu'",host,port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"%s", __func__);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"%s", __func__);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //是否要定义收不到数据的’已断开‘。
    NSLog(@"%s", __func__);
}

#pragma mark - < getter >
- (GCDAsyncSocket*)httpSocket {
    if (_httpSocket == nil) {
        _httpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _httpSocket;
}

- (GCDAsyncSocket *)httpsSocket {
    if (_httpsSocket == nil) {
        _httpsSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _httpsSocket;
}

@end

