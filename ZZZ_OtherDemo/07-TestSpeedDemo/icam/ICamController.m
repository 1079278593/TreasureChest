//
//  ICamController.m
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import "ICamController.h"

#import "DDLog.h"

#import "ICamTcpRelay.h"
#import "ICamServer.h"

#define kWebSocetServerProxyPort    (9081)
#define kHttpServerProxyPort    (8080)
#define kCameraServerPort   (8989)

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface ICamController () <ICamTcpRelayConnectionDelegate, ICamTcpRelayDelegate, ICamChannelDelegate, ICamServerDelegate>

@property (strong, nonatomic) ICamTcpRelay *httpProxy;
@property (strong, nonatomic) ICamTcpRelay *wbSocetProxy;
@property (strong, nonatomic) ICamServer *camera;
@property (strong, nonatomic) NSMutableArray *channels;
@property (strong, nonatomic) NSMutableArray *conns;
@property (assign, nonatomic) BOOL started;

@end

@implementation ICamController

- (id)init
{
    self = [super init];
    if (self) {
        _wbSocetProxy = [[ICamTcpRelay alloc] init];
        _httpProxy = [[ICamTcpRelay alloc] init];
        _camera = [[ICamServer alloc] init];
        [_camera setDelegate:self];
    }
    return self;
}

- (NSMutableArray*)channels
{
    if (_channels == nil) {
        _channels = [[NSMutableArray alloc] init];
    }
    return _channels;
}

- (NSMutableArray*)conns
{
    if (_conns == nil) {
        _conns = [[NSMutableArray alloc] init];
    }
    return _conns;
}

- (void)resume
{
    if (self.started) {
        NSLog(@"tspeed resume skip, isStarted");
        return;
    }
    self.started = YES;
    [self.camera startOnPort:kCameraServerPort callback:^(NSError *error) {
        if (error) {
            DDLogError(@"start camera server on port %u, error %@", kCameraServerPort, error);
        } else {
            DDLogInfo(@"start camera server on port %u", kCameraServerPort);
        }
    }];
    
    [self.httpProxy setDelegate:self];
    [self.httpProxy listentOnPort:kHttpServerProxyPort forward:80 callback:^(NSError *error) {
        if (error) {
            DDLogError(@"start proxy server on port %u, error %@", kHttpServerProxyPort, error);
        } else {
            DDLogInfo(@"start proxy server on port %u", kHttpServerProxyPort);
        }
    }];
    
    [self.wbSocetProxy setDelegate:self];
    [self.wbSocetProxy listentOnPort:kWebSocetServerProxyPort forward:81 callback:^(NSError *error) {
        if (error) {
            DDLogError(@"start proxy server on port %u, error %@", kWebSocetServerProxyPort, error);
        } else {
            DDLogInfo(@"start proxy server on port %u", kWebSocetServerProxyPort);
        }
    }];
}

- (void)pause
{
    self.started = NO;
    [self.camera stop];
    [self.httpProxy stop];
    [self.wbSocetProxy stop];
    for (ICamTcpRelayConnection *conn in self.conns) {
        [conn close];
    }
    [self.conns removeAllObjects];
    [self.channels removeAllObjects];
}

- (void)startLiveStream
{
    [self.camera startLiveStream];
}

- (void)stopLiveStream
{
    [self.camera stopLiveStream];
}

#pragma mark - ICamTcpRelayDelegate
- (void)newConnection:(ICamTcpRelayConnection *)conn port:(unsigned short)port
{
    DDLogDebug(@"new proxy connection %u", port);
    [conn setDelegate:self];
    
    NSLog(@"tspeed ICamController收到新的socket，交给ICamServer? port:%u",port);
    
    __weak ICamController *weakSelf = self;
    [self.camera addTransportChannel:port callback:^(NSError *error, ICamChannel *channel) {
        if (channel) {
            [weakSelf.conns addObject:conn];
            [weakSelf.channels addObject:channel];
            [channel setDelegate:weakSelf];
        }
    }];
}

#pragma mark - ICamTcpRelayConnectionDelegate
- (void)conn:(ICamTcpRelayConnection *)conn didReadData:(NSData *)data
{
    NSUInteger index = [self.conns indexOfObject:conn];
    if (NSNotFound == index) {
        return;
    }
    ICamChannel *channel = [self.channels objectAtIndex:index];
    [channel sendData:data];
}

- (void)closeConnection:(ICamTcpRelayConnection *)conn
{
    DDLogDebug(@"close proxy connection");
    NSUInteger index = [self.conns indexOfObject:conn];
    if (index != NSNotFound) {
        ICamChannel *channel = [self.channels objectAtIndex:index];
        [self.camera removeTransportChannel:channel];
    }
}

#pragma mark - ICamChannelDelegate
- (void)channel:(ICamChannel*)channel didReadData:(NSData*)data
{
    NSUInteger index = [self.channels indexOfObject:channel];
    if (NSNotFound == index) {
        return;
    }
    ICamTcpRelayConnection *conn = [self.conns objectAtIndex:index];
    
    [conn writeData:data];
    //从server中外放到这一层。这一层收不到65535大小的data，被过滤了？
}


- (void)didConnectedChannel:(ICamChannel*)channel;
{
//    NSUInteger index = [self.channels indexOfObject:channel];
//    ICamTcpConnection *conn = [self.conns objectAtIndex:index];
}

- (void)didDisconnectedChannel:(ICamChannel*)channel
{
    NSUInteger index = [self.channels indexOfObject:channel];
    if (index == NSNotFound)
        return;

    ICamTcpRelayConnection *conn = [self.conns objectAtIndex:index];
    
    [conn close];
    
    [self.channels removeObjectAtIndex:index];
    [self.conns removeObjectAtIndex:index];
}

#pragma mark - ICamServerDelegate
- (void)didConnectedClient
{
    if ([self.delegate respondsToSelector:@selector(iCamControllerDidConnectedClent)]) {
        [self.delegate iCamControllerDidConnectedClent];
    }
}

- (void)didDisConnectedClient
{
    if ([self.delegate respondsToSelector:@selector(iCamControllerDidDisconnectedClent)]) {
        [self.delegate iCamControllerDidDisconnectedClent];
    }
}

- (void)onStreamData:(const void *)data size:(size_t)size
{

}

@end
