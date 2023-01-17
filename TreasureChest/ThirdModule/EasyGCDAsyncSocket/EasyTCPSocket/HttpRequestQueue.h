//
//  HttpRequest.h
//  AwesomeCamera
//
//  Created by chenpz on 14-10-29.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KNotificationSocketConnect @"socket connect status"  //socket 断开或者连接状态：YES~连接，NO~断开

typedef void (^HttpCommandRequestCompletionBlock)(NSError *error, int statusCode, NSData *data);

@protocol HttpRequestQueueDelegate <NSObject>

- (void)socketConnect:(BOOL)isConnect;

@end



@interface HttpRequest: NSObject

@end

@interface HttpRequestQueue : NSObject

@property(nonatomic, weak)id<HttpRequestQueueDelegate> delegate;
@property(nonatomic, strong)NSString *host;

+ (instancetype)shareInstance;

- (void)connectWithHost:(NSString *)host port:(NSUInteger)port;

- (void)cancelAll;
- (void)disconnect;

///进来的频率可能是read~250ms(会调整)，可能是set~200ms。判断依据是params是否为nil，nil代表read,
- (void)request:(NSString*)suffixUrl params:(NSDictionary *)params timeout:(NSTimeInterval)timeout completion:(HttpCommandRequestCompletionBlock)completion;

@end
