//
//  HttpRequestQueue.h
//  AwesomeCamera
//
//  Created by chenpz on 14-10-29.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyTCPSocket.h"
#import "HttpRequest.h"

@interface HttpRequestQueue : NSObject

@property(nonatomic, weak)id<HttpRequestQueueDelegate> delegate;
@property(nonatomic, strong)NSString *host;

- (void)connectWithHost:(NSString *)host port:(NSUInteger)port;

- (void)cancelAll;
- (void)disconnect;

///进来的频率可能是read~250ms(会调整)，可能是set~200ms。判断依据是params是否为nil，nil代表read,
///suffixUrl： /light/mode     或者    /ver
///params来区分post和get，get传nil
///HttpCommandRequestCompletionBlock的data用EasySocketModel来解析
- (void)request:(NSString*)suffixUrl params:(NSDictionary *)params timeout:(NSTimeInterval)timeout completion:(HttpCommandRequestCompletionBlock)completion;

- (BOOL)isConnected;

@end

/**参考
 
 POST /light/mode HTTP/1.1
 Host: 192.168.9.67
 Content-Type: application/json
 Accept: ,,,,
 h-time: 1645422751364
 User-Agent: TreasureChest/1.0.0 (iPhone; iOS 15.0; Scale/3.00)
 Accept-Language: en;q=1, el-US;q=0.9
 Content-Length: 48
 Accept-Encoding: gzip, deflate
 Connection: keep-alive

 {"key":"value","key":{"key":0,"key":5000,"key":0}}
 */
