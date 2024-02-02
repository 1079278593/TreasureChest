//
//  EasySocketQueuesManager.m
//  Lighting
//
//  Created by imvt on 2022/6/15.
//

#import "EasySocketQueuesManager.h"
#import "GCDAsyncSocket.h"
#import "HttpRequest.h"

@interface EasySocketQueuesManager ()

@property(nonatomic, strong)NSMutableArray <HttpRequestQueue *> *queues;
@end

@implementation EasySocketQueuesManager

static EasySocketQueuesManager *manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EasySocketQueuesManager alloc]init];
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
        self.queues = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

#pragma mark - < public >
- (HttpRequestQueue *)connectWithHost:(NSString *)host port:(NSUInteger)port {
    HttpRequestQueue *queue = [self getRequestQueueWithHost:host];
    if (queue == nil) {
        queue = [[HttpRequestQueue alloc]init];
        [self.queues addObject:queue];
    }
    if (![queue isConnected]) {
        [queue connectWithHost:host port:port];
    }
    return queue;
}

- (void)stopAllConnects {
    for (HttpRequestQueue *queue in self.queues) {
        [queue disconnect];
    }
}

- (HttpRequestQueue *)getRequestQueueWithHost:(NSString *)host {
    for (HttpRequestQueue *queue in self.queues) {
        if ([queue.host isEqualToString:host]) {
            return queue;
        }
    }
    return nil;
}

@end
