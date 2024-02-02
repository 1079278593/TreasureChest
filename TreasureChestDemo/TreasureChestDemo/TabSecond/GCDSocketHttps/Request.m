//
//  Request.m
//  AwesomeCamera
//
//  Created by imvt on 2024/1/22.
//  Copyright © 2024 ImagineVision. All rights reserved.
//

#import "Request.h"
#import "NSString+Decryption.h"

@interface Request ()

@property(nonatomic, strong)NSString *ip;
@property(nonatomic, assign)AuthHeaderType headerType;

@property(nonatomic, strong)NSString *cmd;
@property(nonatomic, assign)NSTimeInterval timeout;

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *password;
@property(nonatomic, strong)NSString *cookie;
@property(nonatomic, strong)NSString *www_auth;

@end

@implementation Request

- (instancetype)initWithIp:(NSString *)ip headerType:(AuthHeaderType)headerType {
    if (self = [super init]) {
        self.ip = ip;
        self.headerType = headerType;
    }
    return self;
}

#pragma mark - < public >
- (void)prepareWithName:(NSString *)name password:(NSString *)password www_auth:(NSString *)www_authenticate {
    self.name = name;
    self.password = password;
    self.www_auth = www_authenticate;
}

- (void)prepareWithCookie:(NSString *)cookie {
    self.cookie = cookie;
}

- (void)requestWithCmd:(NSString *)cmd timeout:(NSUInteger)timeout {
    self.cmd = cmd;
    self.timeout = timeout;
}

- (NSString *)getRequestHeader {
    NSMutableString *requestHeader = [self defaultHeader:self.ip cmd:self.cmd];
    switch (self.headerType) {
        case AuthHeaderTypeDefault:
            {} break;
        case AuthHeaderTypeCookie:
            {
                [requestHeader appendFormat:@"Cookie: %@\r\n",self.cookie];
            }
            break;
        case AuthHeaderTypeBasic:
            {
                // 'Authorization': 'Basic ' + base64(username + ":" + password)
                NSString *targetString = [NSString stringWithFormat:@"%@:%@",self.name,self.password];
                NSString *auth = [self beingBase64String:targetString];
                [requestHeader appendFormat:@"Authorization: Basic %@\r\n",auth];
            }
            break;
        case AuthHeaderTypeDigest:
            {
                NSString *digestAuth = [self digestPart];
                [requestHeader appendFormat:@"Authorization: Digest %@\r\n", digestAuth];
            }
            break;
            
        default:
            break;
    }
    
    [requestHeader appendFormat:@"\r\n"];
    
    NSLog(@"process next request:%@",requestHeader);
    return requestHeader;
}

#pragma mark - < header >
- (NSMutableString *)defaultHeader:(NSString *)ip cmd:(NSString *)cmd {
    NSString *url = [cmd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//转义：中文 空格等一些特殊的字符
    NSMutableString *requestHeader = [NSMutableString stringWithCapacity:0];
    [requestHeader appendFormat:@"GET %@ HTTP/1.1\r\n",url];
    [requestHeader appendFormat:@"Host: %@\r\n",ip];//其中Host这一行如果不传值，返回的结果中是没有’IP或者域名‘
    [requestHeader appendFormat:@"Connection: keep-alive\r\n"];
    return requestHeader;
}

- (NSString *)digestPart {
    NSString *username = self.name;
    NSString *password = self.password;
    NSString *uri = self.cmd;           //你要访问的资源路径: "/protected"
    NSString *method = @"GET";          // HTTP 方法，如 GET, POST 等
    
    NSString *realm = @"";              //从质询中获得的realm
    NSString *nonce = @"";              //从质询中获得的nonce
    NSString *opaque = @"";             //从质询中获得的opaque
    NSArray *auths = [self.www_auth componentsSeparatedByString:@","];
    for (NSString *tmp in auths) {
        if ([tmp containsString:@"realm"]) {
            realm = [tmp componentsSeparatedByString:@"="].lastObject;
        }
        if ([tmp containsString:@"nonce"]) {
            nonce = [tmp componentsSeparatedByString:@"="].lastObject;
        }
        if ([tmp containsString:@"opaque"]) {
            opaque = [tmp componentsSeparatedByString:@"="].lastObject;
        }
    }
    // HA1 = MD5(username:realm:password)
    NSString *HA1 = [NSString md5ToString:[NSString stringWithFormat:@"%@:%@:%@", username, realm, password]];

    // HA2 = MD5(method:uri)
    NSString *HA2 = [NSString md5ToString:[NSString stringWithFormat:@"%@:%@", method, uri]];

    // Response = MD5(HA1:nonce:HA2)
    NSString *response = [NSString md5ToString:[NSString stringWithFormat:@"%@:%@:%@", HA1, nonce, HA2]];

    // 构建 Authorization 头部
    NSString *authHeader = [NSString stringWithFormat:@"username=\"%@\", realm=\"%@\", nonce=\"%@\", uri=\"%@\", response=\"%@\", opaque=\"%@\"", username, realm, nonce, uri, response, opaque];
    return authHeader;
}

#pragma mark - < private >
- (NSString *)beingBase64String:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [data base64EncodedStringWithOptions:0];
    return result;
}

@end
