//
// A universal frame-based communication protocol which can be used to exchange
// arbitrary structured data.  一种通用的基于帧的通信协议，可用于交换任意结构化数据。
//
// In short:
//
// - Each transmission is comprised by one fixed-size frame.每个传输由一个固定大小的帧组成。
// - Each frame contains a protocol version number.         每帧包含一个协议版本号。
// - Each frame contains an application frame type.         每个帧包含一个应用程序帧类型。
// - Each frame can contain an identifying tag.             每个帧可以包含一个识别标签。
// - Each frame can have application-specific data of up to UINT32_MAX size.每帧可以有应用特定的数据，最大的UINT32_MAX大小。
// - Transactions style messaging can be modeled on top using frame tags.事务样式的消息传递可以使用框架标记在顶部建模。
// - Lightweight API on top of libdispatch (aka GCD) -- close to the metal.框架libdispatch(GCD)之上的轻量级API——接近Metal。
//
#include <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

// Special frame tag that signifies "no tag". Your implementation should never
// create a reply for a frame with this tag.
// 特殊的帧标记，表示“没有标记”。您的实现不应该为带有此标记的帧创建应答。
static const uint32_t PTFrameNoTag = 0;

// Special frame type that signifies that the stream has ended.
// 表示流已经结束的特殊帧类型。
static const uint32_t PTFrameTypeEndOfStream = 0;

// NSError domain
FOUNDATION_EXPORT NSString * const PTProtocolErrorDomain;


@interface PTProtocol : NSObject

// Queue on which to run data processing blocks.
@property dispatch_queue_t queue;

// Get the shared protocol object for *queue*
// 为*queue*获取的共享协议对象
+ (PTProtocol*)sharedProtocolForQueue:(dispatch_queue_t)queue;

// Initialize a new protocol object to use a specific queue.
// 用一个特定的queue初始化一个新的协议对象
- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

// Initialize a new protocol object to use the current calling queue.
// 使用当前的调用队列，初始化一个新的协议对象
- (id)init;

#pragma mark - < Sending frames >

// Generate a new tag that is unique within this protocol object.
// 生成一个在此协议对象中唯一的新标记
- (uint32_t)newTag;

// Send a frame over *channel* with an optional payload and optional callback.
// If *callback* is not NULL, the block is invoked when either an error occured
// or when the frame (and payload, if any) has been completely sent.
// 通过*channel*发送一个带有可选负载和可选回调的帧。如果*callback*不是NULL
// ，当一个错误发生或帧(和有效负载，如果有)已经被完全发送时，该块被调用。
- (void)sendFrameOfType:(uint32_t)frameType
                    tag:(uint32_t)tag
            withPayload:(dispatch_data_t)payload
            overChannel:(dispatch_io_t)channel
               callback:(void(^)(NSError *error))callback;

#pragma mark - < Receiving frames >

// Read frames over *channel* as they arrive.
// The onFrame handler is responsible for reading (or discarding) any payload
// and call *resumeReadingFrames* afterwards to resume reading frames.
// To stop reading frames, simply do not invoke *resumeReadingFrames*.
// When the stream ends, a frame of type PTFrameTypeEndOfStream is received.
// 当帧到达时通过*channel*读取帧。onFrame处理器负责读取(或丢弃)任何有效载荷，
// 然后调用*resumeReadingFrames*来恢复读取帧。
// 要停止读取帧，只需不调用*resumeReadingFrames*。
// 当流结束时，一个类型为PTFrameTypeEndOfStream的帧被接收。
- (void)readFramesOverChannel:(dispatch_io_t)channel
                      onFrame:(void(^)(NSError *error,
                                       uint32_t type,
                                       uint32_t tag,
                                       uint32_t payloadSize,
                                       dispatch_block_t resumeReadingFrames))onFrame;

// Read a single frame over *channel*. A frame of type PTFrameTypeEndOfStream
// denotes the stream has ended.
// 通过*channel*读取单个帧。类型为PTFrameTypeEndOfStream的帧表示流已经结束。
- (void)readFrameOverChannel:(dispatch_io_t)channel
                    callback:(void(^)(NSError *error,
                                      uint32_t frameType,
                                      uint32_t frameTag,
                                      uint32_t payloadSize))callback;

#pragma mark - < Receiving frame payloads >

// Read a complete payload. It's the callers responsibility to make sure
// payloadSize is not too large since memory will be automatically allocated
// where only payloadSize is the limit.
// The returned dispatch_data_t object owns *buffer* and thus you need to call
// dispatch_retain on *contiguousData* if you plan to keep *buffer* around after
// returning from the callback.
// 读取完整的负载。调用方有责任确保payloadSize不要太大，
// 因为在只有payloadSize是限制的地方将自动分配内存。
// 返回的dispatch_data_t对象拥有*buffer*，
// 因此你需要在* continuousdata *上调用dispatch_retain，
// 如果你打算在从回调返回后保留*buffer* around。
- (void)readPayloadOfSize:(size_t)payloadSize
              overChannel:(dispatch_io_t)channel
                 callback:(void(^)(NSError *error,
                                   dispatch_data_t contiguousData,
                                   const uint8_t *buffer,
                                   size_t bufferSize))callback;

// Discard data of *size* waiting on *channel*. *callback* can be NULL.
// 丢弃在*通道*上等待的*大小*的数据。*callback*可以是NULL。
- (void)readAndDiscardDataOfSize:(size_t)size
                     overChannel:(dispatch_io_t)channel
                        callback:(void(^)(NSError *error, BOOL endOfStream))callback;

@end

#pragma mark - < Category >

@interface NSData (PTProtocol)
// Creates a new dispatch_data_t object which references the receiver and uses
// the receivers bytes as its backing data. The returned dispatch_data_t object
// holds a reference to the recevier. It's the callers responsibility to call
// dispatch_release on the returned object when done.
// 创建一个新的dispatch_data_t对象，它引用接收方并使用接收方字节作为它的备份数据。
// 返回的dispatch_data_t对象包含对接收方的引用。
// 调用方的职责是在完成后对返回的对象调用dispatch_release。
- (dispatch_data_t)createReferencingDispatchData;
+ (NSData *)dataWithContentsOfDispatchData:(dispatch_data_t)data;
+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data;
@end

@interface NSDictionary (PTProtocol)
// See description of -[NSData(PTProtocol) createReferencingDispatchData]
- (dispatch_data_t)createReferencingDispatchData;
@end
