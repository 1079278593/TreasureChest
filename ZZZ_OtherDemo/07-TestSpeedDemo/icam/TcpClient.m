//
//  TcpClient.m
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import "TcpClient.h"

#import "GCDAsyncSocket.h"

@interface TcpClient () <GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *sock;
@end

@implementation TcpClient

- (void)connectToHost:(NSString*)host onPort:(uint16_t)port
{
    self.sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.sock connectToHost:host onPort:port error:nil];
}

- (void)disconnect
{
    [self.sock disconnect];
}

- (void)writeData:(NSData*)data
{
    [self.sock writeData:data withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"tcp client connected to host");
    
    [self.sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.delegate client:self didReadData:data];
    [self.sock readDataWithTimeout:-1 tag:0];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@%u -> %@:%u", [_sock localHost], [_sock localPort], [_sock connectedHost], [_sock connectedPort]];
}

@end
