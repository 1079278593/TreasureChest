//
//  TcpClient.h
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//  没用到

#import <Foundation/Foundation.h>

@class TcpClient;

@protocol TcpClientDelegate <NSObject>

- (void)client:(TcpClient*)client didReadData:(NSData *)data;

@end

@interface TcpClient : NSObject
@property (weak, nonatomic) id<TcpClientDelegate> delegate;

- (void)connectToHost:(NSString*)host onPort:(uint16_t)port;
- (void)disconnect;
- (void)writeData:(NSData*)data;
@end
