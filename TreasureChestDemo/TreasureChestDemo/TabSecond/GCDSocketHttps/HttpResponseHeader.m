//
//  HttpResponseHeader.m
//  AwesomeCamera
//
//  Created by imvt on 2024/1/20.
//  Copyright © 2024 ImagineVision. All rights reserved.
//

#import "HttpResponseHeader.h"

@implementation HttpResponseHeader

- (instancetype)init {
    if (self = [super init]) {
        _statusCode = 400;
    }
    return self;
}

@end
