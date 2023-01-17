//
//  EasyUDPSocket.h
//  Lighting
//
//  Created by xiao ming on 2022/3/26.
//

#import <Foundation/Foundation.h>
#define KLightUdpPort 8668
#define KUDPSocketOpcodeHigh 0x80

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    UDPSocketOpcodeWrite = 0,           //!< write，0x8000~32768，用KUDPSocketOpcodeHigh拼接。
    UDPSocketOpcodeRead,                //!< read，;0x8001
} UDPSocketOpcode;

/**
 | opcode (2 byte) | payload |
 payload按照蓝牙的约定的协议(数据格式）。
 调用函数：sendData()来请求，data是最终组装好的数据。
 sendData()本质是send，对外面具体业务而言可能是：1.从设备read；2.write数据到设备;
 */

@interface EasyUDPSocket : NSObject

- (void)startWithHost:(NSString *)host BindWithPort:(NSUInteger)port;
- (void)sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
