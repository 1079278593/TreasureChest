//
//  ICamConnection.h
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import <Foundation/Foundation.h>

struct icam_msg;

@class GCDAsyncSocket;

@protocol ICamConnectionDelegate <NSObject>

- (void)handlePeerChannelMessage:(struct icam_msg*)msg;
- (void)handleTransportData:(NSData*)data from:(unsigned int)channelId;
- (void)handleDisconnected;

@end

@interface ICamConnection : NSObject
@property (weak, nonatomic) id<ICamConnectionDelegate> delegate;

- (id)initWithSocket:(GCDAsyncSocket*)sock delegate:(id<ICamConnectionDelegate>)delegate;

- (void)ping;
- (void)pong;
- (void)newTransportChannel:(unsigned int)channel port:(unsigned short)port;
- (void)deleteTransportChannel:(unsigned int)channel;
- (void)linkUpChannel:(unsigned int)channel;
- (void)linkDownChannel:(unsigned int)channel;
- (void)liveStreamCtrl:(unsigned char)cmd;

//外界传入data，上面的都是内部组装，然后调用这个函数。
- (void)writeTransportData:(NSData*)data to:(unsigned int)channel;
@end
