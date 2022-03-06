//
//  XMNetworking.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "XMNetworking.h"
#import "AFNetworking.h"

//自己替换baseURL
static NSString *const BaseURL = @"https://www.";

@interface XMNetworking()

@property (strong, nonatomic) AFHTTPSessionManager *AFManager;

@end

@implementation XMNetworking

+ (instancetype)shareInstance {
    static XMNetworking *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[XMNetworking alloc] init];
    });
    return _sharedSingleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.AFManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
        self.AFManager = [XMNetworking getSessionManager];
        self.AFManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // FIXME: 此处应该添加一些服务器指定的的请求头信息
        //[self.AFManager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
        
        
        // 返回JSON格式
        self.AFManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.AFManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html", nil];
    }
    return self;
}


- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
//    return [self.AFManager GET:URLString parameters:parameters progress:nil success:success failure:failure];
    AFHTTPSessionManager *session = [XMNetworking getSessionManager];
    return [session GET:URLString parameters:parameters headers:nil progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
//    return [self.AFManager POST:URLString parameters:parameters progress:nil success:success failure:failure];
    return [self.AFManager POST:URLString parameters:parameters headers:nil progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)upload:(NSString *)URLString
                        filePath:(NSString *)filePath
                        fileName:(NSString *)fileName
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                      parameters:(id)parameters
                        progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = [self.AFManager POST:URLString parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name fileName:fileName mimeType:mimeType error:nil];
    } progress:uploadProgress success:success failure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    body:(id)parameters
                       success:(void (^)(id _Nullable responseObject))success
                       failure:(void (^)(NSError * _Nonnull error))failure {
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:nil error:nil];
    long time = [[NSDate date] timeIntervalSince1970]*1000;
    [request setValue:[NSString stringWithFormat:@"%ld",time] forHTTPHeaderField:@"h-time"];  // 请求时间
    [request willChangeValueForKey:@"timeoutInterval"];
    request.timeoutInterval = 10.f;                                                           // 设置超时时间
    [request didChangeValueForKey:@"timeoutInterval"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //Content-Length,如果需要
    
    // 设置body 在这里将参数放入到body(如果你不需要将通过body传 那就参数放入parameters里面)
    NSData *body = [NSJSONSerialization dataWithJSONObject:parameters options:NSUTF8StringEncoding error:nil];
    [request setHTTPBody:body];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"application/xml", nil];
    manager.responseSerializer = responseSerializer;
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response,id responseObject,NSError *error){
        if (error) {
            failure(error);
        }else {
            success([responseObject mj_JSONObject]);
        }
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)upload:(NSString *)URLString
                        fileData:(NSData *)fileData
                        fileName:(NSString *)fileName
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                      parameters:(id)parameters
                        progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *task = [self.AFManager POST:URLString parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:uploadProgress success:success failure:failure];
    
    return task;
}

#pragma mark - < header >
//引力区
+ (AFHTTPSessionManager *)getSessionManager_ylq {
    // 创建请求管理对象
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer = [AFJSONResponseSerializer serializer];

    long time = [[NSDate date] timeIntervalSince1970]*1000;
    [session.requestSerializer setValue:[NSString stringWithFormat:@"%ld",time] forHTTPHeaderField:@"h-time"];  // 请求时间
    [session.requestSerializer setValue:@"ylq" forHTTPHeaderField:@"h-tenant-code"];                            // 租户编码
    [session.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    session.requestSerializer.timeoutInterval = 10.f;                                                           // 设置超时时间
    [session.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    //token调试用
    NSString *token = @"eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhcGlfdXVpZCIsImgtdGVuYW50LWNvZGUiOiJnY3loIiwibG9naW5JZCI6IjgyYzgwN2E3NGRjOTQ5NTBhY2ZhOTIzOWNkZGYwZDBlIiwiZXhwIjoxNzM1MDI2OTY2LCJpYXQiOjE1NjIyMjY5NjUzODF9.X9yy2774tYVAyxDGBN3lmZF7SaX1fvTeZLtFwJ4lPoVLKHa3XggQCUal_jALLnWO-fhoCmpHcR9-STdDvPZetA";
    [session.requestSerializer setValue:token forHTTPHeaderField:@"h-token"];
    
    return session;
}

#pragma mark - < header >
//通用
+ (AFHTTPSessionManager *)getSessionManager {
    // 创建请求管理对象
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer = [AFJSONResponseSerializer serializer];
    [session.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    session.requestSerializer.timeoutInterval = 10.f;                                                           // 设置超时时间
    [session.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    return session;
}

@end

