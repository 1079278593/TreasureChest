#import "PTUSBHub.h"
#import "PTPrivate.h"

#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/un.h>
#include <err.h>

NSString * const PTUSBHubErrorDomain = @"PTUSBHubError";

typedef uint32_t USBMuxPacketType;
enum {
  USBMuxPacketTypeResult = 1,
	USBMuxPacketTypeConnect = 2,
	USBMuxPacketTypeListen = 3,
  USBMuxPacketTypeDeviceAdd = 4,
  USBMuxPacketTypeDeviceRemove = 5,
  // ? = 6,
  // ? = 7,
  USBMuxPacketTypePlistPayload = 8,
};

typedef uint32_t USBMuxPacketProtocol;
enum {
  USBMuxPacketProtocolBinary = 0,
  USBMuxPacketProtocolPlist = 1,
};

typedef uint32_t USBMuxReplyCode;
enum {
  USBMuxReplyCodeOK = 0,
  USBMuxReplyCodeBadCommand = 1,
  USBMuxReplyCodeBadDevice = 2,
  USBMuxReplyCodeConnectionRefused = 3,
  // ? = 4,
  // ? = 5,
  USBMuxReplyCodeBadVersion = 6,
};


typedef struct usbmux_packet {
  uint32_t size;
  USBMuxPacketProtocol protocol;
  USBMuxPacketType type;
  uint32_t tag;
  char data[0];
} __attribute__((__packed__)) usbmux_packet_t;

static const uint32_t kUsbmuxPacketMaxPayloadSize = UINT32_MAX - (uint32_t)sizeof(usbmux_packet_t);


static uint32_t usbmux_packet_payload_size(usbmux_packet_t *upacket) {
  return upacket->size - sizeof(usbmux_packet_t);
}


static void *usbmux_packet_payload(usbmux_packet_t *upacket) {
  return (void*)upacket->data;
}


static void usbmux_packet_set_payload(usbmux_packet_t *upacket,
                                      const void *payload,
                                      uint32_t payloadLength)
{
  memcpy(usbmux_packet_payload(upacket), payload, payloadLength);
}


static usbmux_packet_t *usbmux_packet_alloc(uint32_t payloadSize) {
  assert(payloadSize <= kUsbmuxPacketMaxPayloadSize);
  uint32_t upacketSize = sizeof(usbmux_packet_t) + payloadSize;
  usbmux_packet_t *upacket = CFAllocatorAllocate(kCFAllocatorDefault, upacketSize, 0);
  memset(upacket, 0, sizeof(usbmux_packet_t));
  upacket->size = upacketSize;
  return upacket;
}


static usbmux_packet_t *usbmux_packet_create(USBMuxPacketProtocol protocol,
                                             USBMuxPacketType type,
                                             uint32_t tag,
                                             const void *payload,
                                             uint32_t payloadSize)
{
  usbmux_packet_t *upacket = usbmux_packet_alloc(payloadSize);
  if (!upacket) {
    return NULL;
  }
  
  upacket->protocol = protocol;
  upacket->type = type;
  upacket->tag = tag;
  
  if (payload && payloadSize) {
    usbmux_packet_set_payload(upacket, payload, (uint32_t)payloadSize);
  }
  
  return upacket;
}


static void usbmux_packet_free(usbmux_packet_t *upacket) {
  CFAllocatorDeallocate(kCFAllocatorDefault, upacket);
}


NSNotificationName const PTUSBDeviceDidAttachNotification = @"PTUSBDeviceDidAttachNotification";
NSNotificationName const PTUSBDeviceDidDetachNotification = @"PTUSBDeviceDidDetachNotification";

PTUSBHubNotificationKey const PTUSBHubNotificationKeyDeviceID = @"DeviceID";
PTUSBHubNotificationKey const PTUSBHubNotificationKeyMessageType = @"MessageType";
PTUSBHubNotificationKey const PTUSBHubNotificationKeyProperties = @"Properties";

static NSString *kPlistPacketTypeListen = @"Listen";
static NSString *kPlistPacketTypeConnect = @"Connect";

// Represents a channel of communication between the host process and a remote
// (device) system. In practice, a PTUSBChannel is connected to a usbmuxd
// endpoint which is configured to either listen for device changes (the
// PTUSBHub's channel is usually configured as a device notification listener) or
// configured as a TCP bridge (e.g. channels returned from PTUSBHub's
// connectToDevice:port:callback:). You should not create channels yourself, but
// let PTUSBHub provide you with already configured channels.
// 表示主机进程和远程(设备)系统之间的通信通道。在实践中，PTUSBChannel连接到usbmuxd端点，
// 该端点被配置为侦听设备更改(PTUSBHub的通道通常被配置为设备通知侦听器)或
// 配置为TCP桥接器(例如，从PTUSBHub的connectToDevice:port:callback:返回的通道)。
// 您不应该自己创建通道，而应该让PTUSBHub为您提供已经配置好的通道。
@interface PTUSBChannel : NSObject {
  dispatch_io_t channel_;
  dispatch_queue_t queue_;
  uint32_t nextPacketTag_;
  NSMutableDictionary *responseQueue_;
  BOOL autoReadPackets_;
  BOOL isReadingPackets_;
}

// The underlying dispatch I/O channel. This is handy if you want to handle your
// own I/O logic without PTUSBChannel. Remember to dispatch_retain() the channel
// if you plan on using it as it might be released from the PTUSBChannel at any
// point in time.
//底层调度I/O通道。如果您想在没有PTUSBChannel的情况下处理自己的I/O逻辑，这是很方便的。
//如果您计划使用通道，请记住dispatch_retain()，因为它可能在任何时间从PTUSBChannel释放。
@property (readonly) dispatch_io_t dispatchChannel;

// The underlying file descriptor. 底层的文件描述符。
@property (readonly) dispatch_fd_t fileDescriptor;

// Send data
- (void)sendDispatchData:(dispatch_data_t)data callback:(void(^)(NSError*))callback;
- (void)sendData:(NSData*)data callback:(void(^)(NSError*))callback;

// Read data
- (void)readFromOffset:(off_t)offset length:(size_t)length callback:(void(^)(NSError *error, dispatch_data_t data))callback;

// Close the channel, preventing further reads and writes, but letting currently
// queued reads and writes finish.
// 关闭通道，阻止进一步的读和写，但让当前排队的读和写完成。
- (void)cancel;

// Close the channel, preventing further reads and writes, immediately
// terminating any ongoing reads and writes.
// 关闭通道，防止进一步的读写，立即终止任何正在进行的读和写。
- (void)stop;

@end


@interface PTUSBChannel (Private)

+ (NSDictionary*)packetDictionaryWithPacketType:(NSString*)messageType payload:(NSDictionary*)payload;
- (BOOL)openOnQueue:(dispatch_queue_t)queue error:(NSError**)error onEnd:(void(^)(NSError *error))onEnd;
- (void)listenWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler callback:(void(^)(NSError*))callback;
- (BOOL)errorFromPlistResponse:(NSDictionary*)packet error:(NSError**)error;
- (uint32_t)nextPacketTag;
- (void)sendPacketOfType:(USBMuxPacketType)type overProtocol:(USBMuxPacketProtocol)protocol tag:(uint32_t)tag payload:(NSData*)payload callback:(void(^)(NSError*))callback;
- (void)sendPacket:(NSDictionary*)packet tag:(uint32_t)tag callback:(void(^)(NSError *error))callback;
- (void)sendRequest:(NSDictionary*)packet callback:(void(^)(NSError *error, NSDictionary *responsePacket))callback;
- (void)scheduleReadPacketWithCallback:(void(^)(NSError *error, NSDictionary *packet, uint32_t packetTag))callback;
- (void)scheduleReadPacketWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler;
- (void)setNeedsReadingPacket;
@end


@interface PTUSBHub () {
  PTUSBChannel *channel_;
}
- (void)handleBroadcastPacket:(NSDictionary*)packet;
@end


@implementation PTUSBHub


+ (PTUSBHub*)sharedHub {
  static PTUSBHub *gSharedHub;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    gSharedHub = [PTUSBHub new];
    [gSharedHub listenOnQueue:dispatch_get_main_queue() onStart:^(NSError *error) {
      if (error) {
        NSLog(@"PTUSBHub failed to initialize: %@", error);
      }
    } onEnd:nil];
  });
  return gSharedHub;
}


- (id)init {
  if (!(self = [super init])) return nil;
  
  return self;
}

// mac端调用，iPhone不走这个类
- (void)listenOnQueue:(dispatch_queue_t)queue onStart:(void(^)(NSError*))onStart onEnd:(void(^)(NSError*))onEnd {
  if (channel_) {
    if (onStart) onStart(nil);
    return;
  }
  channel_ = [PTUSBChannel new];
  NSError *error = nil;
  // 创建socket，与系统的usbmuxd连接，建立io channel：channel_
  if ([channel_ openOnQueue:queue error:&error onEnd:onEnd]) {
    [channel_ listenWithBroadcastHandler:^(NSDictionary *packet) { [self handleBroadcastPacket:packet]; } callback:onStart];
  } else if (onStart) {
    onStart(error);
  }
}


- (void)connectToDevice:(NSNumber*)deviceID port:(int)port onStart:(void(^)(NSError*, dispatch_io_t))onStart onEnd:(void(^)(NSError*))onEnd {
  PTUSBChannel *channel = [PTUSBChannel new];
  NSError *error = nil;
  
  if (![channel openOnQueue:dispatch_get_main_queue() error:&error onEnd:onEnd]) {
    onStart(error, nil);
    return;
  }
  
  port = ((port<<8) & 0xFF00) | (port>>8); // limit
  
  NSDictionary *packet = [PTUSBChannel packetDictionaryWithPacketType:kPlistPacketTypeConnect
                                                             payload:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                      deviceID, PTUSBHubNotificationKeyDeviceID,
                                                                      [NSNumber numberWithInt:port], @"PortNumber",
                                                                      nil]];
  
  [channel sendRequest:packet callback:^(NSError *error_, NSDictionary *responsePacket) {
    NSError *error = error_;
    [channel errorFromPlistResponse:responsePacket error:&error];
    onStart(error, (error ? nil : channel.dispatchChannel) );
  }];
}


- (void)handleBroadcastPacket:(NSDictionary*)packet {
  NSString *messageType = [packet objectForKey:PTUSBHubNotificationKeyMessageType];
  
  if ([@"Attached" isEqualToString:messageType]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:PTUSBDeviceDidAttachNotification object:self userInfo:packet];
  } else if ([@"Detached" isEqualToString:messageType]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:PTUSBDeviceDidDetachNotification object:self userInfo:packet];
  } else {
    NSLog(@"Warning: Unhandled broadcast message: %@", packet);
  }
}


@end

#pragma mark -

@implementation PTUSBChannel

+ (NSDictionary*)packetDictionaryWithPacketType:(NSString*)messageType payload:(NSDictionary*)payload {
  NSDictionary *packet = nil;
  
  static NSString *bundleName = nil;
  static NSString *bundleVersion = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    if (infoDict) {
      bundleName = [infoDict objectForKey:@"CFBundleName"];
      bundleVersion = [[infoDict objectForKey:@"CFBundleVersion"] description];
    }
  });
  
  if (bundleName) {
    packet = [NSDictionary dictionaryWithObjectsAndKeys:
              messageType, PTUSBHubNotificationKeyMessageType,
              bundleName, @"ProgName",
              bundleVersion, @"ClientVersionString",
              nil];
  } else {
    packet = [NSDictionary dictionaryWithObjectsAndKeys:messageType, PTUSBHubNotificationKeyMessageType, nil];
  }
  
  if (payload) {
    NSMutableDictionary *mpacket = [NSMutableDictionary dictionaryWithDictionary:payload];
    [mpacket addEntriesFromDictionary:packet];
    packet = mpacket;
  }
  
  return packet;
}


- (id)init {
  if (!(self = [super init])) return nil;
  
  return self;
}


- (void)dealloc {
  if (channel_) {
    channel_ = nil;
  }
}


- (BOOL)valid {
  return !!channel_;
}


- (dispatch_io_t)dispatchChannel {
  return channel_;
}


- (dispatch_fd_t)fileDescriptor {
  return dispatch_io_get_descriptor(channel_);
}

/**
 iTunes使用 usbmux 与 iphone 通信, 它提供了一个USB - TCP的转换服务， 这个服务在Mac端是由/System/Library/PrivateFrameworks/MobileDevice.framework/Resources/usbmuxd提供的, 当然, 开机自动启动。

 它创建了一个Unix Domain Socket 在 /var/run/usbmuxd. usbmuxd服务程序监控iPhone在USB口上的连接,
 当它监控到iPhone以用户模式连接到USB, (相对的是recovery模式),
 usbmuxd服务程序就会连接到这个/var/run/usbmuxd的TCP端口,
 并开始成为一个USB - TCP 请求转发器
 */
- (BOOL)openOnQueue:(dispatch_queue_t)queue error:(NSError**)error onEnd:(void(^)(NSError*))onEnd {
  assert(queue != nil);
  assert(channel_ == nil);
  queue_ = queue;
  
  // Create socket
  dispatch_fd_t fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (fd == -1) {
    if (error) *error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
    return NO;
  }
  
  // prevent SIGPIPE
	int on = 1;
	setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
  
  // Connect socket
  struct sockaddr_un addr;
  addr.sun_family = AF_UNIX;
  strcpy(addr.sun_path, "/private/var/run/usbmuxd");
  socklen_t socklen = sizeof(addr);
  if (connect(fd, (struct sockaddr*)&addr, socklen) == -1) {
    if (error) *error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
    return NO;
  }
  
  channel_ = dispatch_io_create(DISPATCH_IO_STREAM, fd, queue_, ^(int error) {
    close(fd);
    if (onEnd) {
      onEnd(error == 0 ? nil : [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:error userInfo:nil]);
    }
  });

  return YES;
}


- (void)listenWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler callback:(void(^)(NSError*))callback {
  autoReadPackets_ = YES;
  [self scheduleReadPacketWithBroadcastHandler:broadcastHandler];
  
  NSDictionary *packet = [PTUSBChannel packetDictionaryWithPacketType:kPlistPacketTypeListen payload:nil];
  
  [self sendRequest:packet callback:^(NSError *error_, NSDictionary *responsePacket) {
    if (!callback)
      return;
    
    NSError *error = error_;
    [self errorFromPlistResponse:responsePacket error:&error];
    
    callback(error);
  }];
}


- (BOOL)errorFromPlistResponse:(NSDictionary*)packet error:(NSError**)error {
  if (!*error) {
    NSNumber *n = [packet objectForKey:@"Number"];
    
    if (!n) {
      *error = [NSError errorWithDomain:PTUSBHubErrorDomain code:(n ? n.integerValue : 0) userInfo:nil];
      return NO;
    }
    
    USBMuxReplyCode replyCode = (USBMuxReplyCode)n.integerValue;
    if (replyCode != 0) {
      NSString *errmessage = @"Unspecified error";
      switch (replyCode) {
        case USBMuxReplyCodeBadCommand: errmessage = @"illegal command"; break;
        case USBMuxReplyCodeBadDevice: errmessage = @"unknown device"; break;
        case USBMuxReplyCodeConnectionRefused: errmessage = @"connection refused"; break;
        case USBMuxReplyCodeBadVersion: errmessage = @"invalid version"; break;
        default: break;
      }
      *error = [NSError errorWithDomain:PTUSBHubErrorDomain code:replyCode userInfo:[NSDictionary dictionaryWithObject:errmessage forKey:NSLocalizedDescriptionKey]];
      return NO;
    }
  }
  return YES;
}


- (uint32_t)nextPacketTag {
  return ++nextPacketTag_;
}


- (void)sendRequest:(NSDictionary*)packet callback:(void(^)(NSError*, NSDictionary*))callback {
  uint32_t tag = [self nextPacketTag];
  [self sendPacket:packet tag:tag callback:^(NSError *error) {
    if (error) {
      callback(error, nil);
      return;
    }
    // TODO: timeout un-triggered callbacks in responseQueue_
		if (!self->responseQueue_) self->responseQueue_ = [NSMutableDictionary new];
		[self->responseQueue_ setObject:callback forKey:[NSNumber numberWithUnsignedInt:tag]];
  }];
  
  // We are awaiting a response
  [self setNeedsReadingPacket];
}


- (void)setNeedsReadingPacket {
  if (!isReadingPackets_) {
    [self scheduleReadPacketWithBroadcastHandler:nil];
  }
}


- (void)scheduleReadPacketWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler {
  assert(isReadingPackets_ == NO);
  
  [self scheduleReadPacketWithCallback:^(NSError *error, NSDictionary *packet, uint32_t packetTag) {
      // Interpret the package we just received：解释我们刚收到的包裹
      if (packetTag == 0) {
          // Broadcast message
          if (broadcastHandler) broadcastHandler(packet);
      } else if (self->responseQueue_) {
          // Reply
          NSNumber *key = [NSNumber numberWithUnsignedInt:packetTag];
          void(^requestCallback)(NSError*,NSDictionary*) = [self->responseQueue_ objectForKey:key];
          if (requestCallback) {
              [self->responseQueue_ removeObjectForKey:key];
              requestCallback(error, packet);
          } else {
              NSLog(@"Warning: Ignoring reply packet for which there is no registered callback. Packet => %@", packet);
          }
      }
      // Schedule reading another incoming package：安排阅读另一个传入包
      if (self->autoReadPackets_) {
          [self scheduleReadPacketWithBroadcastHandler:broadcastHandler];
      }
  }];
}


- (void)scheduleReadPacketWithCallback:(void(^)(NSError*, NSDictionary*, uint32_t))callback {
  static usbmux_packet_t ref_upacket;
  isReadingPackets_ = YES;

  // Read the first `sizeof(ref_upacket.size)` bytes off the channel_
  dispatch_io_read(channel_, 0, sizeof(ref_upacket.size), queue_, ^(bool done, dispatch_data_t data, int error) {
    if (!done)
      return;
    
    if (error) {
			self->isReadingPackets_ = NO;
      callback([[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:error userInfo:nil], nil, 0);
      return;
    }
    
    // Read size of incoming usbmux_packet_t
    uint32_t upacket_len = 0;
    char *buffer = NULL;
    size_t buffer_size = 0;
    PT_PRECISE_LIFETIME_UNUSED dispatch_data_t map_data = dispatch_data_create_map(data, (const void **)&buffer, &buffer_size); // objc_precise_lifetime guarantees 'map_data' isn't released before memcpy has a chance to do its thing
    assert(buffer_size == sizeof(ref_upacket.size));
    assert(sizeof(upacket_len) == sizeof(ref_upacket.size));
    memcpy((void *)&(upacket_len), (const void *)buffer, buffer_size);

    // Allocate a new usbmux_packet_t for the expected size
    uint32_t payloadLength = upacket_len - (uint32_t)sizeof(usbmux_packet_t);
    usbmux_packet_t *upacket = usbmux_packet_alloc(payloadLength);
    
    // Read rest of the incoming usbmux_packet_t
    off_t offset = sizeof(ref_upacket.size);
		dispatch_io_read(self->channel_, offset, upacket->size - offset, self->queue_, ^(bool done, dispatch_data_t data, int error) {
      //NSLog(@"dispatch_io_read X,Y: done=%d data=%p error=%d", done, data, error);
      
      if (!done) {
        return;
      }
      
			self->isReadingPackets_ = NO;
      
      if (error) {
        callback([[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:error userInfo:nil], nil, 0);
        usbmux_packet_free(upacket);
        return;
      }

      if (upacket_len > kUsbmuxPacketMaxPayloadSize) {
        callback(
          [[NSError alloc] initWithDomain:PTUSBHubErrorDomain code:1 userInfo:@{
            NSLocalizedDescriptionKey:@"Received a packet that is too large"}],
          nil,
          0
        );
        usbmux_packet_free(upacket);
        return;
      }
      
      // Copy read bytes onto our usbmux_packet_t
      char *buffer = NULL;
      size_t buffer_size = 0;
      PT_PRECISE_LIFETIME_UNUSED dispatch_data_t map_data = dispatch_data_create_map(data, (const void **)&buffer, &buffer_size);
      assert(buffer_size == upacket->size - offset);
      memcpy(((void *)(upacket))+offset, (const void *)buffer, buffer_size);

      // We only support plist protocol
      if (upacket->protocol != USBMuxPacketProtocolPlist) {
        callback([[NSError alloc] initWithDomain:PTUSBHubErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"Unexpected package protocol" forKey:NSLocalizedDescriptionKey]], nil, upacket->tag);
        usbmux_packet_free(upacket);
        return;
      }
      
      // Only one type of packet in the plist protocol
      if (upacket->type != USBMuxPacketTypePlistPayload) {
        callback([[NSError alloc] initWithDomain:PTUSBHubErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"Unexpected package type" forKey:NSLocalizedDescriptionKey]], nil, upacket->tag);
        usbmux_packet_free(upacket);
        return;
      }
      
      // Try to decode any payload as plist
      NSError *err = nil;
      NSDictionary *dict = nil;
      if (usbmux_packet_payload_size(upacket)) {
        dict = [NSPropertyListSerialization propertyListWithData:[NSData dataWithBytesNoCopy:usbmux_packet_payload(upacket) length:usbmux_packet_payload_size(upacket) freeWhenDone:NO] options:NSPropertyListImmutable format:NULL error:&err];
      }
      
      // Invoke callback
      callback(err, dict, upacket->tag);
      usbmux_packet_free(upacket);
    });
  });
}


- (void)sendPacketOfType:(USBMuxPacketType)type
            overProtocol:(USBMuxPacketProtocol)protocol
                     tag:(uint32_t)tag
                 payload:(NSData*)payload
                callback:(void(^)(NSError*))callback
{
  assert(payload.length <= kUsbmuxPacketMaxPayloadSize);
  usbmux_packet_t *upacket = usbmux_packet_create(
    protocol,
    type,
    tag,
    payload ? payload.bytes : nil,
    (uint32_t)(payload ? payload.length : 0)
  );
  dispatch_data_t data = dispatch_data_create((const void*)upacket, upacket->size, queue_, ^{
    // Free packet when data is freed
    usbmux_packet_free(upacket);
  });
  [self sendDispatchData:data callback:callback];
}


- (void)sendPacket:(NSDictionary*)packet tag:(uint32_t)tag callback:(void(^)(NSError*))callback {
  NSError *error = nil;
  // NSPropertyListBinaryFormat_v1_0
  NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:packet format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
  if (!plistData) {
    callback(error);
  } else {
    [self sendPacketOfType:USBMuxPacketTypePlistPayload overProtocol:USBMuxPacketProtocolPlist tag:tag payload:plistData callback:callback];
  }
}


- (void)sendDispatchData:(dispatch_data_t)data callback:(void(^)(NSError*))callback {
  off_t offset = 0;
  dispatch_io_write(channel_, offset, data, queue_, ^(bool done, dispatch_data_t data, int _errno) {
    //NSLog(@"dispatch_io_write: done=%d data=%p error=%d", done, data, error);
    if (!done)
      return;
    if (callback) {
      NSError *err = nil;
      if (_errno) err = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:_errno userInfo:nil];
      callback(err);
    }
  });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-getter-return-value"

- (void)sendData:(NSData*)data callback:(void(^)(NSError*))callback {
  dispatch_data_t ddata = dispatch_data_create((const void*)data.bytes, data.length, queue_, ^{
    // trick to have the block capture and retain the data
    [data length];
  });
  [self sendDispatchData:ddata callback:callback];
}

#pragma clang diagnostic pop

- (void)readFromOffset:(off_t)offset length:(size_t)length callback:(void(^)(NSError *error, dispatch_data_t data))callback {
  dispatch_io_read(channel_, offset, length, queue_, ^(bool done, dispatch_data_t data, int _errno) {
    if (!done)
      return;
    
    NSError *error = nil;
    if (_errno != 0) {
      error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:_errno userInfo:nil];
    }

    callback(error, data);
  });
}


- (void)cancel {
  if (channel_) {
    dispatch_io_close(channel_, 0);
  }
}


- (void)stop {
  if (channel_) {
    dispatch_io_close(channel_, DISPATCH_IO_STOP);
  }
}

@end
