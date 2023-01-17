//
//  EasyUDPSocket.m
//  Lighting
//
//  Created by xiao ming on 2022/3/26.
//

#import "EasyUDPSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "UDPServer.h"

@interface EasyUDPSocket () <GCDAsyncUdpSocketDelegate>

@property(nonatomic, strong)UDPServer *udpServer;//暂时放这。

@property (strong, nonatomic)GCDAsyncUdpSocket * udpSocket;
@property(nonatomic, strong)NSString *host;
@property(nonatomic, assign)NSUInteger port;

@end

@implementation EasyUDPSocket

- (instancetype)init {
    if (self = [super init]) {
        _udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            _udpServer = [[UDPServer alloc]init];
//            [_udpServer udpServer];
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        });
        
    }
    return self;
}

#pragma mark - < public >
- (void)startWithHost:(NSString *)host BindWithPort:(NSUInteger)port {
    self.host = host;
    self.port = port;
    
    NSError * error = nil;
    [_udpSocket bindToPort:port error:&error];
    
    //服务端
//    [_udpSocket enableBroadcast:YES error:&error];
    
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        /**
         * 接收信息有两种方法
         * [_udpSocket receiveOnce:&error]此方法是一条一条数据接收,用途往往是先发广播,接收到信息后使用TCP进行长连接，故只接收一条数据即可。
         * [_udpSocket beginReceiving:&error]此方法是持续接收,像本Demo是用来聊天,自然是要持续接收信息,故使用此方法进行接收数据
         */
        [_udpSocket beginReceiving:&error];
    }
}

- (void)sendData:(NSData *)data {
    [_udpSocket sendData:data toHost:self.host port:self.port withTimeout:-1 tag:0];
}

#pragma mark - < delegate >
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    NSLog(@"didNotConnect");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"udpSocketDidClose");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送信息成功");
    [self showLog:@"发送信息成功"];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"发送信息失败");
    [self showLog:@"发送信息失败"];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *log = [NSString stringWithFormat:@"接收到%@的消息:%@",address,data];
    NSLog(@"%@",log);
    [self showLog:log];
}

- (void)showLog:(NSString *)log {
    [EasyProgress showMessage:log];
}

@end
