//
//  Request.h
//  AwesomeCamera
//
//  Created by imvt on 2024/1/22.
//  Copyright © 2024 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseHeader.h"

typedef void (^HttpCommandRequestCompletionBlock)(NSError *error, HttpResponseHeader *header, NSData *data);

typedef NS_ENUM(NSUInteger, AuthHeaderType) {
    AuthHeaderTypeDefault = 0,       //!<
    AuthHeaderTypeBasic,             //!<
    AuthHeaderTypeDigest,            //!<
    AuthHeaderTypeCookie,            //!<
};

@interface Request : NSObject

@property(nonatomic, strong, readonly)NSString *cmd;
@property(nonatomic, assign, readonly)NSTimeInterval timeout;
@property(nonatomic, strong)HttpCommandRequestCompletionBlock completion;

- (instancetype)initWithIp:(NSString *)ip headerType:(AuthHeaderType)headerType;
- (void)prepareWithName:(NSString *)name password:(NSString *)password www_auth:(NSString *)www_authenticate;
- (void)prepareWithCookie:(NSString *)cookie;

- (void)requestWithCmd:(NSString *)cmd timeout:(NSUInteger)timerout;
- (NSString *)getRequestHeader;

@end
