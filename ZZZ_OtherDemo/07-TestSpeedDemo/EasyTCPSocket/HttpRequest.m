//
//  HttpRequest.m
//  Lighting
//
//  Created by imvt on 2022/6/15.
//

#import "HttpRequest.h"

@interface HttpRequest ()

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
