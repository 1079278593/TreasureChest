//
//  HttpsServerManager.m
//  Lighting
//
//  Created by imvt on 2022/2/9.
//

#import "HttpsServerManager.h"
#import "NetworkTool.h"

@implementation HttpsServerManager

static HttpsServerManager *manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpsServerManager alloc]init];
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

#pragma mark - < 搭建本地服务器 并且启动 >
- (void)configLocalHttpServer {
    _localHttpServer = [[HTTPServer alloc] init];
    [_localHttpServer setType:@"_http._tcp"];
//    [_localHttpServer setDomain:@"xxx.com"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = KWebPath;
    NSLog(@"搭建服务：[WebFilePath:]%@",path);
    
    
    if (![fileManager fileExistsAtPath:KWebPath]){
        NSLog(@"搭建服务： File path error!");
    }else{
        NSString *webLocalPath = KWebPath;
        [_localHttpServer setDocumentRoot:webLocalPath];//设置服务器的根目录
        [_localHttpServer setConnectionClass:[UploadFileConnection class]];
        NSLog(@"搭建服务：webLocalPath:%@",webLocalPath);
        [self startServer];
    }
}

- (void)startServer {
    NSError *error;
    if([_localHttpServer start:&error]){
        NSString *ip = [NetworkTool getIPAddress:YES];
        NSLog(@"开始服务：Started HTTP Server on port ---------%hu--------", [_localHttpServer listeningPort]);
        NSLog(@"开始服务：https://localhost:%hu ,手机用WKWeb打开",[_localHttpServer listeningPort]);
        NSLog(@"开始服务：https://%@:%hu  http还是https，如果输入不对无法访问",ip,[_localHttpServer listeningPort]);
        self.port = [NSString stringWithFormat:@"%d",[_localHttpServer listeningPort]];
    }
    else{
        NSLog(@"开始服务：Error starting HTTP Server: %@", error);
    }
}

@end



