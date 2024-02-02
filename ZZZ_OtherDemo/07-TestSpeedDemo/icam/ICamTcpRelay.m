//
//  ICAMTcpRelay.m
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import "ICamTcpRelay.h"
#import "GCDAsyncSocket.h"

@interface ICamTcpRelayConnection () <GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *sock;
@end

@implementation ICamTcpRelayConnection

- (void)setSock:(GCDAsyncSocket *)sock
{
    [_sock setDelegate:nil];
    _sock = sock;
    [sock setDelegate:self];
    [self.sock readDataWithTimeout:-1 tag:0];
}

- (void)writeData:(NSData*)data
{
    [self.sock writeData:data withTimeout:-1 tag:0];
}

- (void)close
{
    [self.sock disconnect];
    self.sock = nil;
}

#pragma mark - Connection GCDAsyncDelegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.delegate conn:self didReadData:data];
    [self.sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self.delegate closeConnection:self];
    self.sock = nil;
}

@end


@interface ICamTcpRelay () <GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
@property (assign, nonatomic) unsigned short forwardPort;
@end

@implementation ICamTcpRelay

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)listentOnPort:(unsigned short)port forward:(unsigned short)forword callback:(void (^)(NSError* error))callback
{
    NSError *error = nil;
    self.forwardPort = forword;
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.serverSocket acceptOnInterface:@"localhost" port:port error:&error];
    
    if (callback) {
        callback(error);
    }
    NSLog(@"tspeed tcpRelay listen port:%u",port);
}

- (void)stop
{
    [self.serverSocket setDelegate:nil];
    [self.serverSocket disconnect];
    self.serverSocket = nil;
}

#pragma mark - GCDAsyncSocketDelegate
//当用GCDSocket创建一个新的socekt时，这里被触发。(在libicam模块之外任意地方创建socket）
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"%s---%d", __func__, self.forwardPort);
    ICamTcpRelayConnection *conn = [[ICamTcpRelayConnection alloc] init];
    [conn setSock:newSocket];
    
    [self.delegate newConnection:conn port:self.forwardPort];
    NSLog(@"tspeed tcpRelay NewSocket port:%u(拦截？)",self.forwardPort);
}


@end
