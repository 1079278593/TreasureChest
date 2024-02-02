//
//  ICamConnection.m
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import "ICamConnection.h"

#import "GCDAsyncSocket.h"
#include "icam_message.h"

#include "DDLog.h"

enum {
    kGCDTagReadHeader,
    kGCDTagReadPayload,
    kGCDTagWriteHeader,
    kGCDTagWritePayload,
    
    kGCDTagWritePing,
    kGCDTagWritePong,
    kGCDTagNewChannel,
    kGCDTagDeleteChannel,
    kGCDTagLinkUp,
    kGCDTagLinkDown,
    kGCDTagStreamCtrl
};

#define kPacketMaxsize      (0xffff)
#define kWriteTimeout       (2.0f)

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface ICamConnection () <GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *peerSocket;
@property (strong, nonatomic) NSMutableData *inBuffer;
@end


@implementation ICamConnection

- (id)initWithSocket:(GCDAsyncSocket*)sock delegate:(id<ICamConnectionDelegate>)delegate
{
    self = [super init];
    if (self) {
        _peerSocket = sock;
        _peerSocket.delegate = self;
        
        _delegate = delegate;

        [self readPacketHeader];
    }
    return self;
}

- (NSMutableData*)inBuffer
{
    if (_inBuffer == nil) {
        _inBuffer = [[NSMutableData alloc] initWithCapacity:65535];
    }
    
    return _inBuffer;
}

#pragma mark - < read & write >
- (void)readPacketHeader
{
    [self.peerSocket readDataToLength:kPacketHeaderSize withTimeout:-1 buffer:self.inBuffer bufferOffset:0 tag:kGCDTagReadHeader];
}

- (void)readPayload:(unsigned int)size
{
    [self.peerSocket readDataToLength:size withTimeout:-1 buffer:self.inBuffer bufferOffset:[self.inBuffer length] tag:kGCDTagReadPayload];
}

- (void)writeTransportData:(NSData*)data to:(unsigned int)channel
{
    unsigned char header[kPacketHeaderSize];
    unsigned int len = (unsigned int)[data length];
    unsigned int offset = 0;
    
    while (len > kPacketMaxsize) {
        // send header
        icam_message_encode_header((unsigned char*)&header, kPacketHeaderSize, channel, kPacketMaxsize);
        [self.peerSocket writeData:[NSData dataWithBytes:&header length:kPacketHeaderSize] withTimeout:kWriteTimeout tag:kGCDTagWriteHeader];
        
        // send payload
        [self.peerSocket writeData:[data subdataWithRange:NSMakeRange(offset, kPacketMaxsize)] withTimeout:kWriteTimeout tag:kGCDTagWritePayload];
        
        offset += kPacketMaxsize;
        len -= kPacketMaxsize;
    }
    
    if (len > 0) {
        // send header
        icam_message_encode_header((unsigned char*)&header, kPacketHeaderSize, channel, len);
        [self.peerSocket writeData:[NSData dataWithBytes:&header length:kPacketHeaderSize] withTimeout:kWriteTimeout tag:kGCDTagWriteHeader];
        
        // send payload
        [self.peerSocket writeData:[data subdataWithRange:NSMakeRange(offset, len)] withTimeout:kWriteTimeout tag:kGCDTagWritePayload];
    }
}

- (void)ping
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_ping(buf, sizeof(buf));
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagWritePing];
    }
}

- (void)pong
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_pong(buf, sizeof(buf));
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagWritePong];
    }
}

- (void)liveStreamCtrl:(unsigned char)cmd
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_stream_ctrl(buf, sizeof(buf), cmd);
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagStreamCtrl];
    }
}

- (void)newTransportChannel:(unsigned int)channel port:(unsigned short)port
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_new_channel(buf, sizeof(buf), channel, port);
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagNewChannel];
    }
}

- (void)deleteTransportChannel:(unsigned int)channel
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_delete_channel(buf, sizeof(buf), channel);
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagDeleteChannel];
    }
}

- (void)linkUpChannel:(unsigned int)channel
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_channel_linkup(buf, sizeof(buf), channel);
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagLinkUp];
    }
}

- (void)linkDownChannel:(unsigned int)channel
{
    unsigned char buf[32];
    
    unsigned char used = icam_message_encode_channel_linkdown(buf, sizeof(buf), channel);
    if (used > 0) {
        [self writeControlData:[NSData dataWithBytes:buf length:used] tag:kGCDTagLinkDown];
    }
}

- (void)writeControlData:(NSData*)data tag:(unsigned long)tag
{
    if (self.peerSocket) {
        DDLogDebug(@"write tag %ld, %ld", tag, (unsigned long)[data length]);
    }
    [self.peerSocket writeData:data withTimeout:-1 tag:tag];
}

#pragma mark - PeerConnection
- (void)peerDidReadData:(NSData *)data withTag:(long)tag
{
    if (tag == kGCDTagReadHeader) {
        const char * ptr = (const char*)[self.inBuffer bytes];
        struct icam_msg_header header;
        if (icam_message_decode_header(ptr, kPacketHeaderSize, &header) == kPacketHeaderSize) {
            [self readPayload:header.payload_size];
        }
        
    } else if (tag == kGCDTagReadPayload) {
        struct icam_msg msg;
        
        if (icam_message_decode([self.inBuffer bytes], (unsigned int)[self.inBuffer length], &msg) == 0) {
            DDLogError(@"failed to decode message");
        } else {
            if (msg.header.channel == 0) {
                [self.delegate handlePeerChannelMessage:&msg];
            } else {
                [self.delegate handleTransportData:[self.inBuffer subdataWithRange:NSMakeRange(kPacketHeaderSize, [self.inBuffer length] - kPacketHeaderSize)] from:msg.header.channel];
            }
        }
        
        // use the buffer
        [self.inBuffer setLength:0];
        
        [self readPacketHeader];
    }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self peerDidReadData:data withTag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    DDLogDebug(@"did write tag %ld", tag);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self.delegate handleDisconnected];
}

@end
