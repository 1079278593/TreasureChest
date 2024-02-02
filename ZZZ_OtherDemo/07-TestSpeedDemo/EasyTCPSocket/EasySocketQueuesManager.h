//
//  EasySocketQueuesManager.h
//  Lighting
//
//  Created by imvt on 2022/6/15.
//  管理多个socket

#import <Foundation/Foundation.h>
#import "EasyTCPSocket.h"
#import "HttpRequestQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface EasySocketQueuesManager : NSObject

+ (instancetype)shareInstance;

- (HttpRequestQueue *)connectWithHost:(NSString *)host port:(NSUInteger)port;
- (void)stopAllConnects;
- (HttpRequestQueue *)getRequestQueueWithHost:(NSString *)host;

@end

NS_ASSUME_NONNULL_END
