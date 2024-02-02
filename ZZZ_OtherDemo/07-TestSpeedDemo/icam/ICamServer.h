//
//  ICAMServer.h
//  icam
//
//  Created by chenpz on 16/7/17.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class ICamChannel;
@class ICamServer;

@protocol ICamChannelDelegate <NSObject>
@optional
- (void)channel:(ICamChannel*)channel didReadData:(NSData*)data;
- (void)didConnectedChannel:(ICamChannel*)channel;
- (void)didDisconnectedChannel:(ICamChannel*)channel;

@end

@interface ICamChannel : NSObject

@property (weak, nonatomic) id<ICamChannelDelegate> delegate;
- (void)sendData:(NSData *)data;
@end

#pragma mark - ICamServer
@protocol ICamServerDelegate <NSObject>
@optional
- (void)onStreamData:(const void*)data size:(size_t)size;
- (void)didConnectedClient;
- (void)didDisConnectedClient;
@end

@interface ICamServer : NSObject

@property (nonatomic, readonly) BOOL linked;
@property (nonatomic, weak) id<ICamServerDelegate> delegate;

- (void)startOnPort:(unsigned short)port callback:(void (^)(NSError* error))callback;
- (void)stop;

- (void)addTransportChannel:(unsigned short)port callback:(void (^)(NSError *error, ICamChannel *channel))callback;
- (void)removeTransportChannel:(ICamChannel*)channel;

- (void)startLiveStream;
- (void)stopLiveStream;

- (void)sendData:(NSData*)data channel:(ICamChannel*)channel error:(NSError**)error;

@end
