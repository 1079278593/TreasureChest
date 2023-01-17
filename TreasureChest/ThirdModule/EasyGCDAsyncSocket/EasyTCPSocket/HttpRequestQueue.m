//
//  HttpRequest.m
//  AwesomeCamera
//
//  Created by chenpz on 14-10-29.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import "HttpRequestQueue.h"
#import "GCDAsyncSocket.h"

#define GCD_TAG_WRITE_REQUEST       (1)

#define GCD_TAG_READ_HTTP_HEADER    (1)
#define GCD_TAG_READ_HTTP_BODY      (2)
#define GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN   (3)

#define KHttpRequestTimeout 1.5     //超时时间，超过这个时间没响应就要处理
#define KHttpRequestDelayCount 4    //httpRequest积压最大数量，如果超过就处理。至于用时间还是用数量，待测试。
#define KHttpJudgeLostCount 3       //积压6个request * 200ms(request间隔) * 3次清除 = 3.6秒左右。判断为断连。


@interface HttpRequest ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, strong) HttpCommandRequestCompletionBlock completion;
@property (nonatomic) int statusCode;
@end

@implementation HttpRequest

- (id)initWithCommand:(NSString*)command timeout:(NSTimeInterval)timeout completion:(HttpCommandRequestCompletionBlock)completion {
    self = [super init];
    if (self) {
        _url = command;
        _timeout = timeout;
        _completion = completion;
        _statusCode = 400;
    }
    return self;
}

- (HttpRequest *)copyRequest {
    HttpRequest *newRequest = [[HttpRequest alloc]initWithCommand:[self.url copy] timeout:self.timeout completion:_completion];
    return newRequest;
}

@end

@interface HttpRequestQueue () <GCDAsyncSocketDelegate>
@property(nonatomic, assign)unsigned short port;
@property(nonatomic, strong)NSMutableArray *queue;
@property(nonatomic, strong)GCDAsyncSocket *socket;

@property(nonatomic, strong)HttpRequest *currentRequest;
@property(nonatomic, strong)NSString *userAgent;

@property(nonatomic, strong)NSMutableData *content;

@property(nonatomic, assign)NSUInteger lostCount;   //!< 超时次数，3次就算断开。期间会不断的清除中间的点和延迟的点。如果读取到数据就会变为0
@property(nonatomic, assign)BOOL isDisconnectInner; //!< 不通知外面连接或者断开状态。

//调试用
@property(nonatomic, strong)UILabel *showRequestLabel;

@end

@implementation HttpRequestQueue


static HttpRequestQueue *manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpRequestQueue alloc]init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone {
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)connectWithHost:(NSString *)host port:(NSUInteger)port {
    if ([_host isEqualToString:host] && [self.socket isConnected]) {
    }
    
    _host = host;
    _port = port;
    _lostCount = 0;
    
    if (![self.socket isConnected]) {
        NSError *error = nil;
        [self.socket connectToHost:self.host onPort:self.port withTimeout:100000 error:&error];
        if (error != nil) {
            NSLog(@"httpReqeust: connect to host failed %@", error);
        }
    }else {
    }
}

#pragma mark - < pubic >
- (void)cancelAll {
    // TODO: the current request???
    NSLog(@"httpReqeust: %s", __func__);
    self.currentRequest = nil;
    [self.queue removeAllObjects];
}

- (void)disconnect {
    NSLog(@"httpReqeust: %s", __func__);
    [self.socket disconnect];
}

- (void)request:(NSString*)suffixUrl params:(NSDictionary *)params timeout:(NSTimeInterval)timeout completion:(HttpCommandRequestCompletionBlock)completion {
    
    [self processDelayRequest];
    
    if (self.lostCount > KHttpJudgeLostCount) {
        self.isDisconnectInner = NO;//这时要通知
        [self disconnect];
        self.lostCount = 0;
        return;
    }
    
    HttpRequest *request = [[HttpRequest alloc] initWithCommand:suffixUrl timeout:timeout completion:completion];
    request.params = params;
    [self addHttpRequest:request];
}

#pragma mark - < GCDAsyncSocketDelegate >
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"httpReqeust: queue connected");
    
    if (!self.isDisconnectInner) {//因为清除超时点而主动断开，不通知。因为默认NO，所以第一进来是会通知的
        [self processConnect:YES];
    }
    
    self.isDisconnectInner = NO;//重新连接后置为NO
    NSLog(@"3434343：-3-%d",self.isDisconnectInner);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"httpReqeust: queue disconnected %@ %@", self.currentRequest.url, err);
    if ([err code] == GCDAsyncSocketClosedError) {
        HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
        if (block) {
            block(nil, self.currentRequest.statusCode, self.content);
        }
    } else if (err != nil) {
        HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
        if (block) {
            block(err, self.currentRequest.statusCode, self.content);
        }
    } else {
        HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
        if (block) {
            block(nil, self.currentRequest.statusCode, self.content);
        }
    }
    
    [self showLog:err];
    
    if (self.currentRequest != nil) {
        [self removeHttpRequest:self.currentRequest];
         
        self.currentRequest = nil;
    }

    [self processNextRequest];
    
    if (!self.isDisconnectInner) {
        [self processConnect:NO];
        NSLog(@"3434343：-2-%d",self.isDisconnectInner);
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == GCD_TAG_WRITE_REQUEST) {
        // read http respond header
        [sock readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_HEADER];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"httpQueue: didRead data :%lu",self.queue.count);
    if (tag == GCD_TAG_READ_HTTP_HEADER) {
        NSInteger content_length = [self parseContentLength:data];
        int status_code = [self parseStatusCode:data];
        self.currentRequest.statusCode = status_code;
        if (content_length > 0) {
            [sock readDataToLength:content_length withTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_BODY];
        } else if (content_length < 0) {
            [self.content setLength:0];
            [sock readDataWithTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN];
        } else if (content_length == 0){
            HttpCommandRequestCompletionBlock block = [self.currentRequest completion];
            if (block) {
                block(nil, status_code, nil);
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
            block(nil, self.currentRequest.statusCode, data);
        }

        if (self.currentRequest != nil) {
            [self removeHttpRequest:self.currentRequest];
            self.currentRequest = nil;
        }
        [self processNextRequest];
        self.lostCount = 0;
    } else if (tag == GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN) {
        [self.content appendData:data];
        [sock readDataWithTimeout:self.currentRequest.timeout tag:GCD_TAG_READ_HTTP_BODY_LENGTH_UNKNOWN];
    }
}

#pragma mark - < process >
- (void)processConnect:(BOOL)isConnect {
    dispatch_async(dispatch_get_main_queue(), ^{
        //两种方式：代理或者通知
        if ([self.delegate respondsToSelector:@selector(socketConnect:)]) {
            [self.delegate socketConnect:isConnect];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationSocketConnect object:@(isConnect)];
    });
}

- (void)processDelayRequest {
    if (self.queue.count > KHttpRequestDelayCount) {
        self.isDisconnectInner = YES;//断开操作之前
        NSLog(@"3434343：%d",self.isDisconnectInner);
        
        //观察是否有问题。
        self.currentRequest = nil;
        HttpRequest *last;
        for (HttpRequest *request in self.queue) {
            if (request.params) {
                last = request;//[request copyRequest];//set的需要保留最后一个
            }
        }
        NSArray *tmp;
        if (last) {
            tmp = @[last];
        }
        [self.queue removeAllObjects];
        
        if (tmp) {
            [self addHttpRequest:tmp.firstObject];
        }
        
        NSLog(@"httpReqeust: queue remove");
        [self disconnect];

        self.lostCount++;
    }
}

- (void)processNextRequest {
    if ([self.queue count] <= 0) {
        return;
    }

    if (self.currentRequest != nil) {
        return;
    }

    NSLog(@"httpQueue: process next request:%lu",self.queue.count);
    
    HttpRequest *req = nil;
    req = [self.queue firstObject];
    self.currentRequest = req;

    if (![self.socket isConnected]) {
        NSError *error = nil;
        [self.socket connectToHost:self.host onPort:self.port withTimeout:req.timeout error:&error];
        if (error != nil) {
            NSLog(@"httpReqeust: connect to host failed %@", error);
        }
    }

    NSString *httpRequestHeader = nil;
    NSString *suffixPath = req.url;
    NSString *body = [req.params mj_JSONString];//body
    NSString *requestType = body == nil ? @"GET" : @"POST";
    
    if (body == nil) {
        httpRequestHeader = [NSString stringWithFormat:
                             @"GET %@ HTTP/1.1\r\n"
                             "Connection: keep-alive\r\n"
                             "\r\n",
                             suffixPath];//get不用host和port
    }else {
        httpRequestHeader = [NSString stringWithFormat:
                             @"%@ %@ HTTP/1.1\r\n"
                             @"Host: %@:%@\r\n"
                             @"Content-Length: %lu\r\n"
                             @"Connection: keep-alive\r\n"
                             @"\r\n"
                             @"%@\r\n"
                             @"\r\n"
                             ,requestType,suffixPath,
                             self.host,@(self.port),
                             (unsigned long)body.length,
                             body];
    }
    

    [self.content setLength:0];
    [self.socket writeData:[httpRequestHeader dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.0 tag:GCD_TAG_WRITE_REQUEST];
}

#pragma mark - < private >
- (void)addHttpRequest:(HttpRequest*)request {
    if (request == nil) {
        return;
    }
    
    [self.queue addObject:request];

    // 第一个执行，后面的排队。
    if ([self.queue count] == 1) {
        [self processNextRequest];
    }
    NSLog(@"httpQueue: add request:%lu",self.queue.count);
    
    [self showHttpRequest];
}

- (void)removeHttpRequest:(HttpRequest *)request {
    [self.queue removeObject:request];
    NSLog(@"httpQueue: remvoe request:%lu",self.queue.count);
}

/// helper parse
- (int)parseContentLength:(NSData*)data {
    NSString *header = [[NSString alloc] initWithBytes:[data bytes] length:[data length] -1 encoding:NSASCIIStringEncoding];
    NSArray *headers = [header componentsSeparatedByString:@"\r\n"];
    for (NSString *h in headers) {
        NSArray *p = [h componentsSeparatedByString:@":"];
        if ([p count] == 2) {
            if ([@"Content-Length" compare:p[0] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSString *value = p[1];
                return [value intValue];
            }
        }
    }
    return -1;
}

- (int)parseStatusCode:(NSData*)data {
    NSString *header = [[NSString alloc] initWithBytes:[data bytes] length:[data length] -1 encoding:NSASCIIStringEncoding];
    NSArray *headers = [header componentsSeparatedByString:@"\r\n"];
    if ([headers count] > 0) {
        NSString *statusLine = headers[0];
        NSArray *p = [statusLine componentsSeparatedByString:@" "];
        if ([p count] > 1) {
            NSString *statusCode = p[1];
            return [statusCode intValue];
        }
    }
    return 400;
}

#pragma mark - < getter >
- (NSMutableArray*)queue {
    if (_queue == nil) {
        _queue = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _queue;
}

- (NSMutableData*)content {
    if (_content == nil) {
        _content = [[NSMutableData alloc] initWithCapacity:1024];
    }
    return _content;
}

- (GCDAsyncSocket*)socket {
    if (_socket == nil) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

- (NSString *)userAgent {
    if (_userAgent == nil) {
        _userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    }
    return _userAgent;
}

#pragma mark - < debug >
- (UILabel *)showRequestLabel {
    if (_showRequestLabel == nil) {
        _showRequestLabel = [[UILabel alloc]init];
        _showRequestLabel.textColor = [UIColor whiteColor];
        _showRequestLabel.font = [UIFont systemFontOfSize:11];
        _showRequestLabel.frame = CGRectMake(50, 20+10, 150, 20);
        _showRequestLabel.layer.borderWidth = 1;
        [[UIApplication sharedApplication].keyWindow addSubview:_showRequestLabel];
    }
    return _showRequestLabel;
}

- (void)showLog:(NSError *)err {
    NSString *log;
    if (err.code == 32) {
        log = @"管道破裂，重新创建";
    }
    if (err.code == 53) {
        log = @"Software caused connection abort";
        //NSPOSIXErrorDomain Code=53 "Software caused connection abort" UserInfo={NSLocalizedDescription=Software caused connection abort,
    }
    if (err.code == 64) {
        log = @"Host is down";
        //NSPOSIXErrorDomain Code=64 "Host is down" UserInfo={NSLocalizedDescription=Host is down, NSLocalizedFailureReason=Error in connect()
    }
    if (err.code == 7) {
        log = @"Socket closed by remote peer";
    }
    if (log.length == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [EasyProgress showFail:log];
    });
}

- (void)showHttpRequest {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showRequestLabel.text = [NSString stringWithFormat:@"request:%lu, dis:%lu",self.queue.count,self.lostCount];
        self.showRequestLabel.hidden = NO;
    });
}

@end
