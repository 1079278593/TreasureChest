//
//  UDPServer.h
//  TreasureChest
//
//  Created by imvt on 2022/4/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//  udp客户端：连接UdpSocketIP并绑定UdpSocketPort，就可以收到：发送的数据原封返回。

#import <Foundation/Foundation.h>

#define UdpSocketIP   inet_addr("127.0.0.1")
#define UdpSocketPort 1024

NS_ASSUME_NONNULL_BEGIN

@interface UDPServer : NSObject

- (void)udpServer;

@end

NS_ASSUME_NONNULL_END
