//
//  EasyGCDAsyncSocket.m
//  TreasureChest
//
//  Created by imvt on 2022/2/17.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "EasyGCDAsyncSocket.h"
#import <GCDAsyncSocket.h>
#import "EasySocketModel.h"

#define KSendTag 1000
#define KSendPollingTag 1001    //用于轮询获取设备状态(tag没什么用，read和write的tag无法对应)

#define KConnectTimeout 10
#define KReadTimeout 0.5
#define KWriteTimeout 0.7     //如果太短，可能会写失败

NSString *SocketRequestTypeStringMap[] = {
    [SocketRequestTypeGet] = @"GET",
    [SocketRequestTypePost] = @"POST",
};

@interface EasyGCDAsyncSocket () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)GCDAsyncSocket *socket;
@property(nonatomic, strong)NSString *host;
@property(nonatomic, assign)NSUInteger port;
@property(nonatomic, strong)NSString *userAgent;

@property(nonatomic, strong)EasySocketModel *socketModel;

@end

@implementation EasyGCDAsyncSocket

static EasyGCDAsyncSocket *manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EasyGCDAsyncSocket alloc]init];
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
    if (self = [super init]) {
//        [self connectWithHost:@"192.168.0.108" port:80];
        
//        NSDictionary *cfg = @{@"Int":@(0),@"cct":@(7000),@"mg":@(0)};
//        NSDictionary *dict = @{@"mode":@"CCT",@"cfg":cfg};
//        [self socketRequestWithDict:dict path:@"/light/mode"];
    }
    return self;
}

#pragma mark - < public >
- (void)connectWithHost:(NSString *)host port:(NSUInteger)port {
    self.host = host;
    self.port = port;
    
    if (!self.socket.isConnected){
        NSError *error;
        [self.socket connectToHost:host onPort:port withTimeout:KConnectTimeout error:&error];
        if (error) NSLog(@"EasySocket：%@",error);
    }
}

- (void)reconnect {
    NSError *error;
    [self.socket connectToHost:self.host onPort:self.port withTimeout:KConnectTimeout error:&error];
}

- (void)disconnect {
    [self.socket disconnect];
    self.socket = nil;
}

- (void)requestWithType:(SocketRequestType)type dict:(NSDictionary *)dict path:(NSString *)path {
    if (![self.socket isConnected]) {
        [self reconnect];
    }
    NSString *body = [dict mj_JSONString];
    
    NSData *data = [self socketContentsWithType:type path:path body:body];
    [self.socket writeData:data withTimeout:KWriteTimeout tag:KSendTag];
}

//wifi请求返回，有效的数据中：包含的字段
- (BOOL)isValidResponse:(NSString *)response {
    BOOL isValid = ([response containsString:@"mode"] ||
                    [response containsString:@"sw"] ||
                    [response containsString:@"temp"] ||
                    [response containsString:@"upgrade"] ||
                    [response containsString:@"ctrl"] ||
                    [response containsString:@"act"]
                    );
    return isValid;
}

#pragma mark - < delegate >
//已经连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port{
    NSLog(@"EasySocket：连接成功------%@---%d",host,port);
    ///可以发送数据了。
    
    //连接成功或者收到消息，必须开始read，否则将无法收到消息,
    //不read的话，缓存区将会被关闭
    // -1 表示无限时长 ,永久不失效
    [self.socket readDataWithTimeout:KReadTimeout tag:KSendTag];
}

// 连接断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"EasySocket：断开 socket连接 原因:%@",err);
    if (err.code == 32) {
        //管道破裂，重新创建
        [self disconnect];
        [self reconnect];
    }
}

//已经接收服务器返回来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self.socketModel decodeWithResponseData:data];
//    NSLog(@"EasySocket：接收到: %ld 长度的数据,data = %@",data.length,self.socketModel.response);

    NSString *result = self.socketModel.responseContent;
    [self postSocketMessage:result];
    
    [self.socket readDataWithTimeout:KReadTimeout tag:KSendTag];
}

//消息发送成功 代理函数 向服务器 发送消息
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"EasySocket：%ld 发送数据成功",tag);
}

#pragma mark - < private >
- (void)postSocketMessage:(NSString *)message {
    //两种方式：代理或者通知
    if ([self.delegate respondsToSelector:@selector(socketReceivedData:)]) {
        [self.delegate socketReceivedData:message];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationSocketMessage object:message];
}

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
- (NSData *)socketContentsWithType:(SocketRequestType)type path:(NSString *)path body:(NSString *)body {
    if (type == SocketRequestTypeGet) {
        body = @"";
    }
    NSString *requestStr = [NSString stringWithFormat:
                  @"%@ %@ HTTP/1.1\r\n"
                  @"Host: %@:%@\r\n"
                  @"Content-Type: application/json\r\n"
                  @"User-Agent: %@\r\n"
                  @"Content-Length: %lu\r\n"
                  @"Accept-Encoding: gzip, deflate\r\n"
                  @"Connection: keep-alive\r\n"
                  @"\r\n"
                  @"%@\r\n"
                  @"\r\n",
                  SocketRequestTypeStringMap[type],path,
                  self.host,@(self.port),
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

- (EasySocketModel *)socketModel {
    if (_socketModel == nil) {
        _socketModel = [[EasySocketModel alloc]init];
    }
    return _socketModel;
}

- (NSString *)userAgent {
    if (_userAgent == nil) {
        _userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    }
    return _userAgent;
}

@end
