//
//  ICamUsbHost.m
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import "ICamUsbHost.h"

#import "GCDAsyncSocket.h"

#import "ICamConnection.h"
#include "icam_message.h"

#include "TcpClient.h"

#include "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface LocalConnection : NSObject
@property (strong, nonatomic) TcpClient *client;
@property (nonatomic) unsigned int channel;
@end

@implementation LocalConnection

@end

@interface ICamUsbHost () <GCDAsyncSocketDelegate, ICamConnectionDelegate, TcpClientDelegate>
@property (strong, nonatomic) GCDAsyncSocket *sock;
@property (strong, nonatomic) ICamConnection *conn;
@property (strong, nonatomic) NSMutableArray *localConns;
@end

@implementation ICamUsbHost

- (NSMutableArray*)localConns
{
    if (_localConns == nil) {
        _localConns = [[NSMutableArray alloc] init];
    }
    return _localConns;
}

- (void)connect
{
    self.sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.sock connectToHost:@"localhost" onPort:8989 error:nil];
}

- (void)disconnect
{
    [self.sock disconnect];
}

- (void)attach
{
    [self connect];
}

- (void)dettach
{
    [self disconnect];
}

#pragma mark - GCDAsycSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connected");
    self.conn = [[ICamConnection alloc] initWithSocket:sock delegate:self];
    
    [self.conn ping];
}

#pragma mark - ICamConnectionDelegate
- (void)handlePeerChannelMessage:(struct icam_msg*)msg
{
    if (msg->type == kPacketTypePing) {
        
    } else if (msg->type == kPacketTypePong) {
        DDLogDebug(@"device client recv pong");
    } else if (msg->type == kPacketTypeNewChannel) {
        DDLogDebug(@"new channel %u", msg->conn.port);
        
        LocalConnection *localConnection = [[LocalConnection alloc] init];
        localConnection.channel = msg->conn.channel_id;
        localConnection.client = [[TcpClient alloc] init];
        [localConnection.client connectToHost:@"localhost" onPort:msg->conn.port + 1];
        [localConnection.client setDelegate:self];
        
        [self.localConns addObject:localConnection];
        
        [self.conn linkUpChannel:msg->conn.channel_id];
    } else if (msg->type == kPacketTypeDeleteChannel) {
        DDLogDebug(@"delete channel");
        
        [self.conn linkDownChannel:msg->conn.channel_id];
    } else {
        DDLogWarn(@"unhandled msg %d", msg->type);
    }
}

- (void)handleTransportData:(NSData*)data from:(unsigned int)channelId
{
    __block LocalConnection *conn = nil;
    [self.localConns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        conn = (LocalConnection*)obj;
        if (conn.channel == channelId) {
            *stop = YES;
        } else {
            conn = nil;
            *stop = NO;
        }
    }];
    
    [[conn client] writeData:data];
}

- (void)handleDisconnected
{

}

#pragma mark - TcpClientDelegate
- (void)client:(TcpClient*)client didReadData:(NSData *)data
{
    __block LocalConnection *conn = nil;
    [self.localConns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        conn = (LocalConnection*)obj;
        if ([conn.client isEqual:client]) {
            *stop = YES;
        } else {
            conn = nil;
            *stop = NO;
        }
    }];
    [self.conn writeTransportData:data to:[conn channel]];
}

@end
