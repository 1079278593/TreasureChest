//
//  EasyTCPSocket.h
//  Lighting
//
//  Created by imvt on 2022/6/15.
//

#ifndef EasyTCPSocket_h
#define EasyTCPSocket_h

#define KNotificationSocketConnect @"socket connect status"  //socket 断开或者连接状态：YES~连接，NO~断开

typedef void (^HttpCommandRequestCompletionBlock)(NSError *error, int statusCode, NSData *data);

@protocol HttpRequestQueueDelegate <NSObject>

- (void)socketConnect:(BOOL)isConnect;

@end

#endif /* EasyTCPSocket_h */
