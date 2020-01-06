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

+ (instancetype)sharedManager {
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
        self.AFManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
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
    
    return [self.AFManager GET:URLString parameters:parameters progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    return [self.AFManager POST:URLString parameters:parameters progress:nil success:success failure:failure];
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
    NSURLSessionDataTask *task = [self.AFManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name fileName:fileName mimeType:mimeType error:nil];
    } progress:uploadProgress success:success failure:failure];
    
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
    NSURLSessionDataTask *task = [self.AFManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:uploadProgress success:success failure:failure];
    
    return task;
}

@end

