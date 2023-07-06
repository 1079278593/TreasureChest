//
//  EasyUDPSocket.h
//  Lighting
//
//  Created by xiao ming on 2022/3/26.
//

#import <Foundation/Foundation.h>
#define KLightUdpPort 8668
#define KUDPSocketOpcodeHigh 0x80

#define KUDPHeaderSize 6
#define KUDPSeqSize 4
#define KUDPOpcodeIndex 4       //第5位为UDP的：UDPSocketOpcode {0x00,0x00,0x00,0x00,0x80}
#define KUDPSeqTmp {0x00,0x00,0x00,0x00}       //暂时写死

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    UDPSocketOpcodeWrite = 0,           //!< write，0x8000~32768，用KUDPSocketOpcodeHigh拼接。
    UDPSocketOpcodeRead,                //!< read，;0x8001
} UDPSocketOpcode;

typedef enum : NSUInteger {
    FixturesColorModeCCT = 0,       //!< 颜色模式：CCT
    FixturesColorModeHSI = 1,       //!< 颜色模式：HSI
    FixturesColorModeGel = 2,       //!< 颜色模式：Gel
    FixturesColorModeXY = 3,        //!< 颜色模式：x,y coordinates
    FixturesColorModeSource = 4,    //!< 实物光源的：光
//    FixturesColorModeRGB,           //!< 颜色模式：RGB
    FixturesColorModeRGBW = 6,      //!< 颜色模式：RGBW
    FixturesColorModeRGBW_I = 8,    //!< 颜色模式：R/G/B/W/././各通道放开，目前还是所有通道一起发送
    FixturesColorModeEffects = 5,   //!< 颜色模式：effects，内部有各种各样的组合
    
    FixturesColorSetting = 222,     //!< 设置：待删除
    FixturesColorModeNone,          //!< 无模式/所有模式
} FixturesColorMode;

/**
 | opcode (2 byte) | payload |
 payload按照蓝牙的约定的协议(数据格式）。
 调用函数：sendData()来请求，data是最终组装好的数据。
 sendData()本质是send，对外面具体业务而言可能是：1.从设备read；2.write数据到设备;
 */

@interface EasyUDPSocket : NSObject

- (void)startWithHost:(NSString *)host BindWithPort:(NSUInteger)port;
- (void)sendData:(NSData *)data;

- (void)switchHost:(NSString *)host sendData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
