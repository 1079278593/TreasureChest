//
//  EasyWebSocket.m
//  Lighting
//
//  Created by xiao ming on 2022/3/26.
//

#import "EasyWebSocket.h"
#import "SRWebSocket.h"

@interface EasyWebSocket () <SRWebSocketDelegate>

@property(nonatomic, strong)SRWebSocket *webSocket;

@end

@implementation EasyWebSocket

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

#pragma mark - < public >
//初始化socket并且连接
- (void)connectServer:(NSString *)server port:(NSString *)port {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%@",server,port]]];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    _webSocket.delegate = self;
    [_webSocket open];
}

#pragma mark - < delegate >
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"didReceiveMessage:%@",message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"didCloseWithCode:%ld, reason:%@, wasClean:%d",(long)code,reason,wasClean);
}

@end
