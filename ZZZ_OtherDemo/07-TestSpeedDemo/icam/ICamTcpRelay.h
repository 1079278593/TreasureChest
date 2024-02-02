//
//  ICAMTcpRelay.h
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICamTcpRelayConnection;

@protocol ICamTcpRelayConnectionDelegate <NSObject>

@optional
- (void)conn:(ICamTcpRelayConnection*)conn didReadData:(NSData*)data;
- (void)closeConnection:(ICamTcpRelayConnection*)conn;

@end

@interface ICamTcpRelayConnection : NSObject
@property (weak, nonatomic) id<ICamTcpRelayConnectionDelegate> delegate;

- (void)writeData:(NSData*)data;
- (void)close;

@end

@protocol ICamTcpRelayDelegate <NSObject>

@optional
- (void)newConnection:(ICamTcpRelayConnection*)conn port:(unsigned short)port;

@end

@interface ICamTcpRelay : NSObject

@property (weak, nonatomic) id<ICamTcpRelayDelegate> delegate;
- (void)listentOnPort:(unsigned short)port forward:(unsigned short)forward callback:(void (^)(NSError* error))callback;
- (void)stop;

@end
