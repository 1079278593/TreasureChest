//
//  UDPServer.m
//  TreasureChest
//
//  Created by imvt on 2022/4/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "UDPServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation UDPServer

///放在子线程，不然线程会被卡死
- (void)udpServer {
  int serverSockerId = -1;
  ssize_t len = -1;
  socklen_t addrlen;
  char buff[1024];
  struct sockaddr_in ser_addr;
  
  // 第一步：创建socket
  // 注意，第二个参数是SOCK_DGRAM，因为udp是数据报格式的
  serverSockerId = socket(AF_INET, SOCK_DGRAM, 0);
  
  if(serverSockerId < 0) {
    NSLog(@"Create server socket fail");
    return;
  }
  
    NSLog(@"Create server socket success");
    
  addrlen = sizeof(struct sockaddr_in);
  bzero(&ser_addr, addrlen);
  
  ser_addr.sin_family = AF_INET;
//  ser_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  ser_addr.sin_port = htons(UdpSocketPort);
    
    struct in_addr  socketIn_addr;
    socketIn_addr.s_addr    = UdpSocketIP;
    ser_addr.sin_addr = socketIn_addr;
  
  // 第二步：绑定端口号
  if(bind(serverSockerId, (struct sockaddr *)&ser_addr, addrlen) < 0) {
    NSLog(@"server connect socket fail");
    return;
  }
  
    NSLog(@"server connect socket success");
    
  do {
    bzero(buff, sizeof(buff));
    
    // 第三步：接收客户端的消息
    len = recvfrom(serverSockerId, buff, sizeof(buff), 0, (struct sockaddr *)&ser_addr, &addrlen);
    // 显示client端的网络地址
    NSLog(@"receive from %s\n", inet_ntoa(ser_addr.sin_addr));
    // 显示客户端发来的字符串
      if (len > 0) {
          NSLog(@"recevce:%s", buff);
      }
      
    
    // 第四步：将接收到的客户端发来的消息，发回客户端
    // 将字串返回给client端
    sendto(serverSockerId, buff, len, 0, (struct sockaddr *)&ser_addr, addrlen);
  } while (strcmp(buff, "exit") != 0);
  
  // 第五步：关闭socket
  close(serverSockerId);
}



@end
