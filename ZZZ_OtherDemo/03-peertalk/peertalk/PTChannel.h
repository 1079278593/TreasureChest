//
// Represents a communication channel between two endpoints talking the same
// PTProtocol.
//
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <netinet/in.h>
#import <sys/socket.h>

#import <peertalk/PTProtocol.h>
#import <peertalk/PTUSBHub.h>
#import <peertalk/PTDefines.h>

@class PTAddress;
@protocol PTChannelDelegate;

NS_ASSUME_NONNULL_BEGIN

PT_FINAL @interface PTChannel : NSObject

// Delegate
@property (strong, nullable) id<PTChannelDelegate> delegate;

// Communication protocol.
@property PTProtocol *protocol;

// YES if this channel is a listening server
@property (readonly) BOOL isListening;

// YES if this channel is a connected peer
@property (readonly) BOOL isConnected;

// Arbitrary attachment. Note that if you set this, the object will grow by
// 8 bytes (64 bits).
// 任意的附件。注意，如果您设置了这个值，该对象将增长8个字节(64位)。
@property (strong) id userInfo;

// Create a new channel using the shared PTProtocol for the current dispatch
// queue, with *delegate*.
// 使用共享PTProtocol为当前调度队列创建一个新的通道，使用*delegate*。
+ (PTChannel *)channelWithDelegate:(nullable id<PTChannelDelegate>)delegate NS_SWIFT_UNAVAILABLE("");

// Initialize a new frame channel, configuring it to use the calling queue's
// protocol instance (as returned by [PTProtocol sharedProtocolForQueue:
//   dispatch_get_current_queue()])
// 初始化一个新的帧通道，配置它使用调用队列的协议实例(由[PTProtocol sharedProtocolForQueue: dispatch_get_current_queue()]返回)
- (id)init NS_SWIFT_UNAVAILABLE("");

//// Initialize a new frame channel with a specific protocol.
//用特定的协议初始化一个新的帧通道。
- (id)initWithProtocol:(PTProtocol *)protocol NS_SWIFT_UNAVAILABLE("");

// Initialize a new frame channel with a specific protocol and delegate.
- (id)initWithProtocol:(nullable PTProtocol *)protocol delegate:(nullable id<PTChannelDelegate>)delegate NS_SWIFT_NAME(init(protocol:delegate:));

// Connect to a TCP port on a device connected over USB
// 通过USB,连接到一个TCP端口,在一个连接了的设备
- (void)connectToPort:(int)port overUSBHub:(PTUSBHub *)usbHub deviceID:(NSNumber *)deviceID callback:(void(^)(NSError * _Nullable error))callback NS_SWIFT_NAME(connect(to:over:deviceID:callback:));

// Connect to a TCP port at IPv4 address. Provided port must NOT be in network
// byte order. Provided in_addr_t must NOT be in network byte order. A value returned
// from inet_aton() will be in network byte order. You can use a value of inet_aton()
// as the address parameter here, but you must flip the byte order before passing the
// in_addr_t to this function.
// 连接到一个TCP端口在IPv4地址。提供的端口不能处于网络字节顺序。提供in_addr_t不能是网络字节顺序。从inet_aton()返回的值将按网络字节顺序。
// 这里可以使用inet_aton()的值作为地址参数，但是在将in_addr_t传递给这个函数之前必须颠倒字节顺序。
- (void)connectToPort:(in_port_t)port IPv4Address:(in_addr_t)address callback:(void(^)(NSError * _Nullable error, PTAddress *_Nullable address))callback NS_SWIFT_NAME(connect(to:IPv4Address:callback:));

// Listen for connections on port and address, effectively starting a socket
// server. Provided port must NOT be in network byte order. Provided in_addr_t
// must NOT be in network byte order.
// For this to make sense, you should provide a onAccept block handler
// or a delegate implementing ioFrameChannel:didAcceptConnection:.
// 监听端口和地址上的连接，有效地启动套接字服务器。提供的端口不能处于网络字节顺序。提供in_addr_t不能是网络字节顺序。
// 为了让它有意义，你应该提供一个onAccept块处理器或一个实现ioFrameChannel:didAcceptConnection:的委托。
- (void)listenOnPort:(in_port_t)port IPv4Address:(in_addr_t)address callback:(void(^)(NSError * _Nullable error))callback NS_SWIFT_NAME(listen(on:IPv4Address:callback:));

// Send a frame with an optional payload and optional callback.
// If *callback* is not NULL, the block is invoked when either an error occured
// or when the frame (and payload, if any) has been completely sent.
// 发送一个带有可选负载和可选回调的帧。如果*callback*不是NULL，当一个错误发生或帧(和有效负载，如果有)已经被完全发送时，该块被调用。
- (void)sendFrameOfType:(uint32_t)frameType tag:(uint32_t)tag withPayload:(nullable NSData *)payload callback:(nullable void(^)(NSError * _Nullable error))callback NS_SWIFT_NAME(sendFrame(type:tag:payload:callback:));

// Lower-level method to assign a connected dispatch IO channel to this channel
// 将连接的调度IO通道分配给此通道的较低级方法
- (BOOL)startReadingFromConnectedChannel:(dispatch_io_t)channel error:(__autoreleasing NSError **)error NS_SWIFT_NAME(startReading(from:));

// Close the channel, preventing further reading and writing. Any ongoing and
// queued reads and writes will be aborted.
// 关闭通道，防止进一步的读写。任何正在进行的和排队的读和写将被中止。
- (void)close;

// "graceful" close -- any ongoing and queued reads and writes will complete
// before the channel ends.
// 优雅的关闭——任何正在进行和排队的读写将在通道结束之前完成。
- (void)cancel;

@end

// Represents a peer's address
PT_FINAL @interface PTAddress : NSObject
// For network addresses, this is the IP address in textual format
// 对于网络地址，这是文本格式的IP地址
@property (readonly) NSString *name;
// For network addresses, this is the port number. Otherwise 0 (zero).
// 对于网络地址，这是端口号。否则0(零)。
@property (readonly) NSInteger port;
@end


// Protocol for PTChannel delegates
@protocol PTChannelDelegate <NSObject>

@required

// Invoked when a new frame has arrived on a channel.
// 当新帧到达信道时调用。
- (void)ioFrameChannel:(PTChannel *)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(nullable NSData *)payload NS_SWIFT_NAME(channel(_:didRecieveFrame:tag:payload:));



@optional

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
// 调用以接受通道上的传入帧。应答NO忽略传入帧。如果委托没有实现，所有帧都被接受。
- (BOOL)ioFrameChannel:(PTChannel *)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize NS_SWIFT_NAME(channel(_:shouldAcceptFrame:tag:payloadSize:));;

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
// 当通道关闭时调用。如果它因为错误而关闭，*error*是一个非nil NSError对象。
- (void)ioFrameChannel:(PTChannel *)channel didEndWithError:(nullable NSError *)error NS_SWIFT_NAME(channelDidEnd(_:error:));

// For listening channels, this method is invoked when a new connection has been
// accepted.
// 对于侦听通道，在接受新连接时调用此方法。
- (void)ioFrameChannel:(PTChannel *)channel didAcceptConnection:(PTChannel *)otherChannel fromAddress:(PTAddress *)address NS_SWIFT_NAME(channel(_:didAcceptConnection:from:));

@end

NS_ASSUME_NONNULL_END
