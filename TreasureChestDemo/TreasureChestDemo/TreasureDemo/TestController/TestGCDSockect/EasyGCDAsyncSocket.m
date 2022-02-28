//
//  EasyGCDAsyncSocket.m
//  TreasureChest
//
//  Created by imvt on 2022/2/17.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "EasyGCDAsyncSocket.h"
#import <GCDAsyncSocket.h>
#import "XMNetworking.h"

#define KSendTag 1000

@interface EasyGCDAsyncSocket () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket *socket;
@property(nonatomic, strong)NSString *host;
@property(nonatomic, assign)NSUInteger port;

@property(nonatomic, strong)NSString *userAgent;

@end

@implementation EasyGCDAsyncSocket

- (instancetype)init {
    if (self = [super init]) {
//        [self connectWithHost:@"192.168.0.108" port:80];
        
        [self httpRequest];
    }
    return self;
}

#pragma mark - < public >
- (void)connectWithHost:(NSString *)host port:(NSUInteger)port {
    self.host = host;
    self.port = port;
    
    if (!self.socket.isConnected){
        NSError *error;
        [self.socket connectToHost:host onPort:port withTimeout:-1 error:&error];
        if (error) NSLog(@"%@",error);
    }
}

- (void)reconnect {
    NSError *error;
    [self.socket connectToHost:self.host onPort:self.port withTimeout:-1 error:&error];
}

- (void)disconnect {
    [self.socket disconnect];
    self.socket = nil;
}

- (void)socketRequestWithDict:(NSDictionary *)dict path:(NSString *)path {
    if (![self.socket isConnected]) {
        [self reconnect];
    }
    NSString *body = [dict mj_JSONString];
    NSData *data = [self socketDataFromPath:path body:body];
    [self.socket writeData:data withTimeout:-1 tag:KSendTag];
}

///test
- (void)httpRequest {
    //post
//    NSDictionary *cfg = @{@"Int":@(0),@"cct":@(7000),@"mg":@(0)};
//    NSDictionary *dict = @{@"mode":@"CCT",@"cfg":cfg};
//    NSString *url = @"http://192.168.0.108/light/mode";
    
//    [[XMNetworking shareInstance] POST:url body:dict success:^(id  _Nullable responseObject) {
//
//    } failure:^(NSError * _Nonnull error) {
//
//    }];
    
    //get
    NSDictionary *dict = [NSDictionary new];
    NSString *url = @"http://192.168.0.108/light/mode";
    [[XMNetworking shareInstance] GET:url parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
    }];
    
}

#pragma mark - < delegate >
//已经连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功 : %@---%d",host,port);
    ///可以发送数据了。
    
    //连接成功或者收到消息，必须开始read，否则将无法收到消息,
    //不read的话，缓存区将会被关闭
    // -1 表示无限时长 ,永久不失效
    [self.socket readDataWithTimeout:-1 tag:KSendTag];
}

// 连接断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开 socket连接 原因:%@",err);
}

//已经接收服务器返回来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *str = [data mj_JSONString];
    NSLog(@"接收到tag = %ld : %ld 长度的数据,data = %@",tag,data.length,str);
    
    [self.socket readDataWithTimeout:-1 tag:KSendTag];
}

//消息发送成功 代理函数 向服务器 发送消息
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%ld 发送数据成功",tag);
}

#pragma mark - < private >

/**
 POST /light/mode HTTP/1.1
 Host: 192.168.9.67
 Content-Type: application/json
 Accept: ,,,,
 h-time: 1645422751364
 User-Agent: TreasureChest/1.0.0 (iPhone; iOS 15.0; Scale/3.00)
 Accept-Language: en;q=1, el-US;q=0.9
 Content-Length: 48
 Accept-Encoding: gzip, deflate
 Connection: keep-alive

 {"key":"value","key":{"key":0,"key":5000,"key":0}}
 */
- (NSData *)socketDataFromPath:(NSString *)path body:(NSString *)body {
    NSString *requestStr = [NSString stringWithFormat:
                  @"POST %@ HTTP/1.1\r\n"
                  @"Host: %@:%@\r\n"
                  @"Content-Type: application/json\r\n"
                  @"User-Agent: %@\r\n"
                  @"Content-Length: %lu\r\n"
                  @"Accept-Encoding: gzip, deflate\r\n"
                  @"Connection: keep-alive\r\n"
                  @"\r\n"
                  @"%@\r\n"
                  @"\r\n",
                  path,self.host,@(self.port),
                  self.userAgent,(unsigned long)body.length,
                  body
                  ];
    NSData *data = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

#pragma mark - < getter >
- (GCDAsyncSocket *)socket {
    if (_socket == nil) {
        // 并发队列，这个队列将影响delegate回调,但里面是同步函数！保证数据不混乱，一条一条来
        // 这里最好是写自己并发队列
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _socket;
}

- (NSString *)userAgent {
    if (_userAgent == nil) {
        _userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    }
    return _userAgent;
}

@end
