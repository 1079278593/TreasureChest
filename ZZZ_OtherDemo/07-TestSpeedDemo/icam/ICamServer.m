//
//  ICAMServer.m
//  icam
//
//  Created by chenpz on 16/7/17.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import "ICamServer.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <netinet/in.h>

#import <dispatch/dispatch.h>

#import "GCDAsyncSocket.h"
#include "icam_message.h"
#import "ICamConnection.h"

#import "DDLog.h"

#define kPacketMaxsize      (255)
#define kWriteTimeout       (2.0f)

#define KMaxChannelNum      (32)


#define kCommandChannel     (0)
#define kStreamChannel      (1)
#define kUserChannelBase    (2)

enum {
    kGCDTagReadHeader,
    kGCDTagReadPayload,
    kGCDTagWriteHeader,
    kGCDTagWritePayload,
    
    kGCDTagWritePong,
};

static const int ddLogLevel = LOG_LEVEL_DEBUG;

#pragma mark - ICamChannel

@interface ICamChannel ()

@property (strong, nonatomic) NSMutableData *pendingBuf;
@property (nonatomic, readonly) BOOL linked;
@property (weak, nonatomic) ICamServer *server;

@property (nonatomic) unsigned int num;
@property (nonatomic) unsigned short port;

- (id)initWithServer:(ICamServer*)server channel:(unsigned int)channel port:(unsigned short)port;
- (void)sendData:(NSData*)data;

@end

@implementation ICamChannel

- (id)initWithServer:(ICamServer*)server channel:(unsigned int)channel port:(unsigned short)port
{
    self = [super init];
    if (self) {
        _server = server;
        _num = channel;
        _port = port;
        _linked = NO;
    }
    return self;
}

- (NSMutableData*)pendingBuf
{
    if (_pendingBuf == nil) {
        _pendingBuf = [[NSMutableData alloc] init];
    }
    
    return _pendingBuf;
}

- (void)sendData:(NSData *)data
{
    NSError *error = nil;
    if ([self linked]) {
        [self.server sendData:data channel:self error:&error];
    } else {
        [self.pendingBuf appendData:data];
    }
}

- (void)onLinkUp
{
    if ([self.pendingBuf length] > 0) {
        NSError *error = nil;
        [self.server sendData:self.pendingBuf channel:self error:&error];
        [self.pendingBuf setLength:0];
    } else {
        
    }
    _linked = YES;
    
    [self.delegate didConnectedChannel:self];
}

- (void)onLinkDown
{
    _linked = NO;
    [self.pendingBuf setLength:0];
    [self.delegate didDisconnectedChannel:self];
}

- (void)onReadData:(NSData*)data
{
    [self.delegate channel:self didReadData:data];
}

@end


@interface ICamServer () <GCDAsyncSocketDelegate, ICamConnectionDelegate>
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
@property (strong, nonatomic) GCDAsyncSocket *peerSocket;

@property (strong, nonatomic) ICamConnection *conn;

@property (nonatomic) unsigned int *ids;
@property (strong, nonatomic) NSMutableDictionary *connMap; // <id, ICamChannel>

@property (strong, nonatomic) NSMutableArray *pendingConnectChannels;    // <ICamChannel>

@end

@implementation ICamServer

- (id)init
{
    if ([super init]) {
        self.connMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (unsigned int*)ids
{
    if (_ids == nil) {
        _ids = calloc(KMaxChannelNum, sizeof(unsigned int));
    }
    return _ids;
}

- (NSMutableArray*)pendingConnectChannels
{
    if (_pendingConnectChannels == nil) {
        _pendingConnectChannels = [[NSMutableArray alloc] init];
    }
    
    return _pendingConnectChannels;
}

- (BOOL)isLinked
{
    return  self.conn != nil;
}

- (void)startOnPort:(unsigned short)port callback:(void (^)(NSError*))callback
{
    NSError *error = nil;
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.serverSocket acceptOnInterface:nil port:port error:&error];
    if (callback) {
        callback(error);
    }
}

- (void)stop
{
    [self.serverSocket setDelegate:nil];
    [self.serverSocket disconnect];
    self.serverSocket = nil;
    if (self.peerSocket) {
        [self.peerSocket disconnect];
        self.peerSocket = nil;
    }
}

- (void)startLiveStream
{
    [self.conn liveStreamCtrl:1];
}

- (void)stopLiveStream
{
    [self.conn liveStreamCtrl:0];
}

#pragma mark - ProxyConnection
- (void)addTransportChannel:(unsigned short)port callback:(void (^)(NSError *error, ICamChannel *channel))callback
{
    unsigned int loc = 0;
    
    for (unsigned int i = kUserChannelBase; i < KMaxChannelNum; i++) {
        if (self.ids[i] == 0) {
            loc = i;
            break;
        }
    }
    
    if (loc == 0 || loc == KMaxChannelNum) {
        if (callback) {
            callback([NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:nil], nil);
        }
    }
    
    ICamChannel *channel = [[ICamChannel alloc] initWithServer:self channel:loc port:port];
    self.ids[loc] = 1;
    [self.connMap setObject:channel forKey:[NSNumber numberWithUnsignedInteger:loc]];
    
    if ([self isLinked]) {
        DDLogInfo(@"new transport %d", loc);
        [self.conn newTransportChannel:loc port:port];
    } else {
        [self.pendingConnectChannels addObject:channel];
    }
    
    if (callback) {
        callback(nil, channel);
    }
}

- (void)removeTransportChannel:(ICamChannel*)channel
{
    NSUInteger index =  [self.pendingConnectChannels indexOfObject:channel];
    if (index != NSNotFound) {
        DDLogInfo(@"removeTransport NOT found");
        [self.pendingConnectChannels removeObject:channel];
        return;
    }
    
    __block unsigned int channelId = 0;
    [self.connMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ICamChannel *target = (ICamChannel*)obj;
        NSNumber *number = (NSNumber*)key;
        *stop = ([target isEqual:channel]);
        if (*stop) {
            channelId = (unsigned int)[number unsignedIntegerValue];
        }
    }];
    
    [self.connMap removeObjectForKey:[NSNumber numberWithUnsignedInteger:channelId]];
    
    DDLogInfo(@"removeTransport id %d", channelId);
    [self.conn deleteTransportChannel:channelId];
}

- (void)sendData:(NSData*)data channel:(ICamChannel*)channel error:(NSError**)error
{
    __block unsigned int channelId = 0;
    [self.connMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ICamChannel *target = (ICamChannel*)obj;
        NSNumber *number = (NSNumber*)key;
        *stop = ([target isEqual:channel]);
        if (*stop) {
            channelId = (unsigned int)[number unsignedIntegerValue];
        }
    }];
    
    if (channelId) {
//        DDLogDebug(@"send transport data %d %ld", channelId, (unsigned long)[data length]);
        [self.conn writeTransportData:data to:channelId];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:nil];
        }
    }
}

#pragma mark - ICamConnectionDelegate
- (void)handlePeerChannelMessage:(struct icam_msg*)msg
{
    if (msg->type == kPacketTypePing) {
        DDLogInfo(@"[server] recv PING");
        NSLog(@"tspeed ICamServer receiv ping");
        [self.conn pong];//如果没有收到ping，这里的不断循环逻辑是否就 不成立。
        NSLog(@"tspeed ICamServer send pong");
    } else if (msg->type == kPacketTypePong) {
        
    } else if (msg->type == kPacketTypeLinkUp) {
        NSNumber *channel_id = [NSNumber numberWithUnsignedInteger:msg->conn.channel_id];
        ICamChannel *channel = [self.connMap objectForKey:channel_id];
        
        [channel onLinkUp];
    } else if (msg->type == kPacketTypeLinkDown) {
        NSNumber *channel_id = [NSNumber numberWithUnsignedInteger:msg->conn.channel_id];

        if (msg->conn.channel_id < KMaxChannelNum) {
            self.ids[msg->conn.channel_id] = 0;
        }
        
        ICamChannel *channel = [self.connMap objectForKey:channel_id];
        [channel onLinkDown];
    } else {
        DDLogWarn(@"unhandled msg %d", msg->type);
    }
}

- (void)handleTransportData:(NSData*)data from:(unsigned int)channelId
{
    if (channelId == kStreamChannel) {
        [self.delegate onStreamData:[data bytes] size:[data length]];
    } else {
        ICamChannel *channel = [self.connMap objectForKey:[NSNumber numberWithUnsignedInteger:channelId]];
        
        [channel onReadData:data];
    }
}

- (void)handleDisconnected
{
    [self.connMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ICamChannel *channel = (ICamChannel*)obj;
        [channel onLinkDown];
        *stop = NO;
    }];

    [self.connMap removeAllObjects];
    [self.pendingConnectChannels removeAllObjects];
    
    self.conn = nil;
    
    for (unsigned int i = kUserChannelBase; i < KMaxChannelNum; i++) {
        self.ids[i] = 0;
    }
    
    [self.delegate didDisConnectedClient];
    DDLogInfo(@"device client disconnected");
    DDLogInfo(@"--------------------------");
}

#pragma mark - GCDAsyncSocketDelegate (Acceptor)
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //typeC线重新插一下，才能激活和回调这里。
    //存在情况：不走这里了，也无法继续流程。
    NSLog(@"tspeed ICamServer did accept newSocket");
    
    self.peerSocket = newSocket;
    
    // new socket
    self.conn = [[ICamConnection alloc] initWithSocket:newSocket delegate:self];
    [self.conn setDelegate:self];

    // create the stream channel
    [self.conn newTransportChannel:kStreamChannel port:0];
    
    for (ICamChannel *channel in self.pendingConnectChannels) {
        [self.conn newTransportChannel:[channel num] port:[channel port]];
    }
    
    [self.pendingConnectChannels removeAllObjects];
    
    [self.delegate didConnectedClient];
    DDLogInfo(@"+++++++++++++++++++++++++++");
    DDLogInfo(@"new device client connected");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{

}

@end
