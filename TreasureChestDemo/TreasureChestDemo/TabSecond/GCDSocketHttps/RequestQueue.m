//
//  RequestQueue.m
//  AwesomeCamera
//
//  Created by chenpz on 14-10-29.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import "RequestQueue.h"
#import "GCDAsyncSocket.h"

#define GCD_TAG_WRITE_REQUEST       (1)
#define GCD_TAG_READ_HTTP_HEADER    (1)
#define GCD_TAG_READ_HTTP_BODY      (2)
#define GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN   (3)

#pragma mark - < Request Queue >
@interface RequestQueue () <GCDAsyncSocketDelegate>

@property(nonatomic, strong)NSString *ip;
@property(nonatomic, assign)unsigned short port;
@property(nonatomic, strong)NSMutableArray *queue;
@property(nonatomic, strong)NSMutableArray *priorityQueue;
@property(nonatomic, strong)GCDAsyncSocket *socket;

@property(nonatomic, strong)Request *currentRequest;
@property(nonatomic, strong)HttpResponseHeader *currentResponseHeader;

@property(nonatomic, strong)NSMutableData *failContent;

@end

@implementation RequestQueue

- (id)initWithIP:(NSString*)ip andPort:(unsigned short)port {
    self = [super init];
    if (self) {
        _ip = ip;
        _port = port;
        [self connectToHostWithIp:ip port:port timeout:10];
        WS(weakSelf)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//            [weakSelf connectToHostWithIp:@"192.168.1.1" port:port timeout:10];//测试是否会导致前面的断开
        });
    }
    return self;
}

#pragma mark - < public >
- (void)request:(Request *)request completion:(HttpCommandRequestCompletionBlock)completion {
    request.completion = completion;//保留completion
    [self addHttpRequest:request];
    
}

- (void)cancelAll {
    // TODO: the current request???
    NSLog(@"%s", __func__);
    self.currentRequest = nil;
    [self.queue removeAllObjects];
    [self.priorityQueue removeAllObjects];
}

- (void)disconnect {
    NSLog(@"%s", __func__);
    [self.socket disconnect];
}

- (void)startSSL {
    // 一旦连接成功，启动 SSL/TLS
    NSMutableDictionary *sslSettings = [[NSMutableDictionary alloc] init];

    // 在这里配置您的 SSL 设置
    // 例如，'允许自签名证书YES'或'忽略证书链验证~NO'（注意：不安全，仅用于测试）
    [sslSettings setObject:[NSNumber numberWithBool:YES] forKey:GCDAsyncSocketManuallyEvaluateTrust];

    [self.socket startTLS:sslSettings];
    NSLog(@"ReqeustQueue startSSL");
}

#pragma mark - < GCDAsyncSocketDelegate >
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"ReqeustQueue connected");
    [self startSSL];//连接成功后开启
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"ReqeustQueue disconnected %@ %@,statusCode:%d,failContent:%@", self.currentRequest.cmd, err,[self currentResponseHeader].statusCode,self.failContent);
    HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
    if (block) {
        block(err, [self currentResponseHeader], self.failContent);//这里disconnect情况，一般是默认值400（这个旧逻辑，从’CurrentHeader‘取，可能有残留状态。。。）
    }

    if (self.currentRequest != nil) {
        [self removeHttpRequest:self.currentRequest];
         
        self.currentRequest = nil;
    }

    [self processNextRequest];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == GCD_TAG_WRITE_REQUEST) {
        // read http respond header
        [sock readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_HEADER];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == GCD_TAG_READ_HTTP_HEADER) {
        HttpResponseHeader *header = [self parseHeaderFromData:data];//给currentHeader赋值。
        self.currentResponseHeader = header;
        if (header.contentLength > 0) {
            [sock readDataToLength:header.contentLength withTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_BODY];
        } else if (header.contentLength < 0) {
            [self.failContent setLength:0];
            [sock readDataWithTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN];
        } else if (header.contentLength == 0){
            HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
            if (block) {
                block(nil, header, nil);
            }

            if (self.currentRequest != nil) {
                [self removeHttpRequest:self.currentRequest];
                self.currentRequest = nil;
            }
            [self processNextRequest];
        }
    } else if (tag == GCD_TAG_READ_HTTP_BODY) {
        HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
        if (block) {
            block(nil, [self currentResponseHeader], data);
        }

        if (self.currentRequest != nil) {
            [self removeHttpRequest:self.currentRequest];
            self.currentRequest = nil;
        }
        [self processNextRequest];
    } else if (tag == GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN) {
        [self.failContent appendData:data];
        [sock readDataWithTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN];
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    NSLog(@"ReqeustQueue SSL/TLS 握手完成，连接已加密");
    // 在这里发送 HTTPS 请求或进行其他通信
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    // 自定义验证逻辑
    BOOL shouldTrustPeer = NO;

    // 示例：始终信任服务器
    // 注意：这不安全，仅用于测试
    shouldTrustPeer = YES;

    // 或者，使用 SecTrustEvaluate 来验证证书
    /*
    SecTrustResultType result;
    OSStatus status = SecTrustEvaluate(trust, &result);
    if (status == errSecSuccess && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
        // 证书验证成功
        shouldTrustPeer = YES;
    }
    */

    // 调用完成处理器，传递验证结果
    completionHandler(shouldTrustPeer);
    NSLog(@"ReqeustQueue didReceiveTrust");
}

#pragma mark - < connect >
- (void)connectToHostWithRequest:(Request *)request {
    NSTimeInterval timeout = request.timeout;
    NSString *ip = self.ip;
    NSUInteger port = 443;//isHttps ? 443 : self.port;
    
    [self connectToHostWithIp:ip port:port timeout:10];
}

- (void)connectToHostWithIp:(NSString *)ip port:(NSUInteger)port timeout:(NSTimeInterval)timeout {
    if (![self.socket isConnected]) {
        NSError *error = nil;
        [self.socket connectToHost:ip onPort:port withTimeout:timeout error:&error];
        if (error != nil) {
            NSLog(@"connect to host failed %@", error);
        }
    }
}

#pragma mark - < 处理request >
#pragma mark < 新增的request，从这里开始 >
- (void)addHttpRequest:(Request*)request {
    if ([request.cmd containsString:@"/ctrl/icam?"]) {//待替换，
        [self.priorityQueue addObject:request];
    } else {
        [self.queue addObject:request];
    }

    // kick off
    if ([self.queue count] == 1 ||
        ([self.queue count] == 0 && self.priorityQueue.count == 1)) {
        [self processNextRequest];
    }
}

- (void)removeHttpRequest:(Request *)request {
    [self.queue removeObject:request];
    [self.priorityQueue removeObject:request];
}

- (void)processNextRequest {
    if ([self.queue count] <= 0 && [self.priorityQueue count] <= 0) {
        return;
    }

    if (self.currentRequest != nil) {
        return;
    }

    Request *req = nil;
    if (self.priorityQueue.count > 0) {
        req = [self.priorityQueue firstObject];
    } else {
        req = [self.queue objectAtIndex:0];
    }
    self.currentRequest = req;

    [self connectToHostWithRequest:self.currentRequest];
    
    NSLog(@"process next request:%@",self.currentRequest.cmd);
    
    NSString *httpRequestHeader = [self.currentRequest getRequestHeader];
    [self.failContent setLength:0];
    [self.socket writeData:[httpRequestHeader dataUsingEncoding:NSUTF8StringEncoding] withTimeout:3.0 tag:GCD_TAG_WRITE_REQUEST];
}

#pragma mark -- parse
- (HttpResponseHeader *)parseHeaderFromData:(NSData *)data {
    NSString *header = [[NSString alloc] initWithBytes:[data bytes] length:[data length] -1 encoding:NSASCIIStringEncoding];
    NSArray *headers = [header componentsSeparatedByString:@"\r\n"];
    HttpResponseHeader *responeseHeader = [[HttpResponseHeader alloc]init];

    for (NSString *lineContent in headers) {
        if ([lineContent localizedCaseInsensitiveContainsString:@"http/"]) {//第一行一般是形如这样的：HTTP/1.x 200 OK
            NSArray *p = [lineContent componentsSeparatedByString:@" "];
            if ([p count] > 1) {
                NSString *statusCode = p[1];
                responeseHeader.statusCode = [statusCode intValue];//状态码
            }
        }else if ([lineContent localizedCaseInsensitiveContainsString:@"Content-Length"]) {
            NSArray *p = [lineContent componentsSeparatedByString:@":"];
            if ([p count] == 2) {
                NSString *length = p[1];
                responeseHeader.contentLength = [length intValue];
            }
        }else if ([lineContent localizedCaseInsensitiveContainsString:@"location"]) {//重定向的目标url
            /**
             定向1：   Location: https://192.168.31.248/login/
             定向2：   Location: https://192.168.31.248/www/index.html
             */
            NSArray *p = [lineContent componentsSeparatedByString:@" "];
            if ([p count] == 2) {
                NSString *value = p[1];
                responeseHeader.location = value;
            }
        }else if ([lineContent localizedCaseInsensitiveContainsString:@"WWW-Authenticate"]) {//认证方式
            /**下面两种返回
             Basic realm=....
             Digest realm="Z CAM Controller",qop="auth",nonce="bbb1bc9be7141e754080a44047259726b6",opaque="34d2884a78386cc53e42a00af641c5a8"
             */
            NSString *suitString = [lineContent stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *p = [suitString componentsSeparatedByString:@"WWW-Authenticate: "];
            if ([p count] == 2) {
                NSString *value = p[1];
                responeseHeader.www_authenticate = value;
            }
        }else if ([lineContent localizedCaseInsensitiveContainsString:@"Set-Cookie"]) {
            NSArray *p = [lineContent componentsSeparatedByString:@" "];
            if ([p count] == 2) {
                NSString *value = p[1];
                responeseHeader.cookie = value;
            }
        }else {
            
        }
        
    }
    return responeseHeader;
}

#pragma mark - < getter >
- (NSMutableArray*)queue {
    if (_queue == nil) {
        _queue = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _queue;
}

- (NSMutableArray*)priorityQueue {
    if (_priorityQueue == nil) {
        _priorityQueue = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return _priorityQueue;
}

- (NSMutableData*)failContent {
    if (_failContent == nil) {
        _failContent = [[NSMutableData alloc] initWithCapacity:1024];
    }
    return _failContent;
}

- (GCDAsyncSocket*)socket {
    if (_socket == nil) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

@end
