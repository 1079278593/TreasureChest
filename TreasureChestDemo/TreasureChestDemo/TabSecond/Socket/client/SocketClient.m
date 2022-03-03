//
//  SocketClient.m
//  TreasureChest
//
//  Created by imvt on 2022/3/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "SocketClient.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

//htons : 将一个无符号短整型的主机数值转换为网络字节顺序，不同cpu 是不同的顺序 (big-endian大尾顺序 , little-endian小尾顺序)
#define SocketPort htons(8040) //端口
//inet_addr是一个计算机函数，功能是将一个点分十进制的IP转换成一个长整数型数
#define SocketIP   inet_addr("127.0.0.1") // ip

@interface SocketClient ()

//属性，用于接收socket创建成功后的返回值
@property(nonatomic, assign)int clinenId;

@end

@implementation SocketClient

- (instancetype)init {
    if (self = [super init]) {
//        [self startSocket];
    }
    return self;
}

#pragma mark - < public >
/**
 1. terminal输入命令：nc -lk 8040        (其中8040是端口号)
 2. App执行函数：startSocket
 3. 双端任意发送信息
 */
- (void)startClient {
    
    // 1: 创建socket
    int socketID = socket(AF_INET, SOCK_STREAM, 0);
    self.clinenId= socketID;
    if (socketID == -1) {
        NSLog(@"客户端：---创建socket 失败");
        return;
    }
    
    // 2: 连接socket
    struct sockaddr_in socketAddr;
    socketAddr.sin_family = AF_INET;
    socketAddr.sin_port   = SocketPort;
    struct in_addr socketIn_addr;
    socketIn_addr.s_addr  = SocketIP;
    socketAddr.sin_addr   = socketIn_addr;
    
    int result = connect(socketID, (const struct sockaddr *)&socketAddr, sizeof(socketAddr));

    if (result != 0) {
        NSLog(@"客户端：---连接失败");
        return;
    }
    NSLog(@"客户端：---连接成功");
    
    // 调用开始接受信息的方法
    // while 如果主线程会造成堵塞
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self receiveMessage];
    });
}

- (void)sendMessage:(NSString *)content {
    //3: 发送消息
    if (content.length == 0) {
        return;
    }
    const char *msg = content.UTF8String;
    ssize_t sendLen = send(self.clinenId, msg, strlen(msg), 0);
    NSLog(@"客户端：---发送 %ld 字节",sendLen);
}

#pragma mark - < private >
- (void)receiveMessage {
    // 4. 接收数据
    while (1) {
        uint8_t buffer[1024];
        ssize_t recvLen = recv(self.clinenId, buffer, sizeof(buffer), 0);
        NSLog(@"客户端：---接收到了:%ld字节",recvLen);
        if (recvLen == 0) {
            continue;
        }
        // buffer -> data -> string
        NSData *data = [NSData dataWithBytes:buffer length:recvLen];
        NSString *str= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"客户端：---%@---%@",[NSThread currentThread],str);
    }
}

@end
