//
//  EasyGCDAsyncSocket.h
//  TreasureChest
//
//  Created by imvt on 2022/2/17.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define KNotificationSocketMessage @"socket message"        //socket收到的数据，或者用代理方式

typedef enum : NSUInteger {
    SocketRequestTypeGet = 0,           //!< get方式
    SocketRequestTypePost = 1,          //!< post方式
} SocketRequestType;

extern NSString * _Nonnull SocketRequestTypeStringMap[];

@protocol EasySocketDelegate <NSObject>

- (void)socketReceivedData:(NSString *)data;

@end

@interface EasyGCDAsyncSocket : NSObject

@property(nonatomic, weak)id<EasySocketDelegate> delegate;
@property(nonatomic, strong, readonly)NSString *host; //!< IP

+ (instancetype)shareInstance;
- (void)connectWithHost:(NSString *)host port:(NSUInteger)port;
- (void)reconnect;
- (void)disconnect;
- (void)requestWithType:(SocketRequestType)type dict:(NSDictionary *)dict path:(NSString *)path;
- (BOOL)isValidResponse:(NSString *)response;   ///wifi请求返回，有效的数据中：包含的字段
///
@end

NS_ASSUME_NONNULL_END
