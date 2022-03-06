//
//  SocketServer.m
//  TreasureChest
//
//  Created by imvt on 2022/3/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "SocketServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define SocketPort htons(8040)
#define SocketIP   inet_addr("127.0.0.1")
#define KMaxConnectCount 1024 //最大连接数量

@interface SocketServer ()

@property(nonatomic, assign)int serverId;
@property(nonatomic, assign)int client_socket;

@end

@implementation SocketServer

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - < public >
- (void)startServer {
    //1. 创建socket
    self.serverId = socket(AF_INET, SOCK_STREAM, 0);
    if (self.serverId == -1) {
        NSLog(@"服务端：---创建socket 失败");
        return;
    }
    NSLog(@"服务端：---创建socket 成功");
    
    //2.1 addr
    struct sockaddr_in socketAddr;
    socketAddr.sin_family   = AF_INET;
    socketAddr.sin_port     = SocketPort;
    struct in_addr  socketIn_addr;
    socketIn_addr.s_addr    = SocketIP;
    socketAddr.sin_addr     = socketIn_addr;
    bzero(&(socketAddr.sin_zero), 8);
    
    // 2.2 bind socket
    int bind_result = bind(self.serverId, (const struct sockaddr *)&socketAddr, sizeof(socketAddr));
    if (bind_result == -1) {
        NSLog(@"服务端：---绑定socket 失败");
        return;
    }

    NSLog(@"服务端：---绑定socket成功");
    
    //3. monitor socket
    int listen_result = listen(self.serverId, KMaxConnectCount);
    if (listen_result == -1) {
        NSLog(@"服务端：---监听失败");
        return;
    }
    
    NSLog(@"服务端：---监听成功");
    
    //4. accept
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        struct sockaddr_in client_address;
        socklen_t address_len;
        // accept函数：这里之后就处于等待中，直到有客户端连上，才继续执行下面的代码。
        int client_socket = accept(self.serverId, (struct sockaddr *)&client_address, &address_len);
        self.client_socket = client_socket;
        
        if (client_socket == -1) {
            NSLog(@"服务端：---接受 %u 客户端错误",address_len);
        }else{
            NSString *acceptInfo = [NSString stringWithFormat:@"客户端 in,socket:%d",client_socket];
            NSLog(@"服务端：---%@",acceptInfo);
           //5. 开始接受消息
            [self receiveMsgWithClietnSocket:client_socket];
        }
    });
}

- (void)sendMessage:(NSString *)content {
    if (content.length == 0) {
        return;
    }
    const char *msg = content.UTF8String;
    ssize_t sendLen = send(self.client_socket, msg, strlen(msg), 0);
    NSLog(@"服务端：---发送了:%ld字节",sendLen);
}

- (void)closeServer {
    int close_result = close(self.client_socket);
    if (close_result == -1) {
        NSLog(@"服务端：---socket 关闭失败");
        return;
    }else{
        NSLog(@"服务端：---socket 关闭成功");
    }
}

#pragma mark - < private >
- (void)receiveMsgWithClietnSocket:(int)clientSocket {
    while (1) {
        // 5: 接受客户端传来的数据
        char buf[1024] = {0};
        long iReturn = recv(clientSocket, buf, 1024, 0);
        if (iReturn>0) {
            NSLog(@"服务端：---客户端来消息了");
            // 接收到的数据转换
            NSData *recvData  = [NSData dataWithBytes:buf length:iReturn];
            NSString *recvStr = [[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding];
            NSLog(@"服务端：---%@",recvStr);
            
        }else if (iReturn == -1){
            NSLog(@"服务端：---读取消息失败");
            break;
        }else if (iReturn == 0){
            NSLog(@"服务端：---客户端走了");
            
            close(clientSocket);
            
            break;
        }
    }
}

@end
