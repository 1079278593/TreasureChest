//
//  HttpRequest.h
//  AwesomeCamera
//
//  Created by chenpz on 14-10-29.
//  Copyright (c) 2014年 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponseHeader.h"
#import "Request.h"

@interface RequestQueue : NSObject

- (id)initWithIP:(NSString*)ip andPort:(unsigned short)port;

- (void)request:(Request *)request completion:(HttpCommandRequestCompletionBlock)completion;

- (void)cancelAll;
- (void)disconnect;

@end
