//
//  EasySocketModel.m
//  Lighting
//
//  Created by imvt on 2022/2/22.
//

#import "EasySocketModel.h"

@interface EasySocketModel ()


@end

@implementation EasySocketModel

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

#pragma mark - < public >
- (void)decodeWithResponseData:(NSData *)responseData {
    [self reset];
    _response = [responseData mj_JSONString];
    
    NSString *string = [_response stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray *results = [string componentsSeparatedByString:@"\n"];
    _contents = [NSMutableArray arrayWithCapacity:0];
    for (NSString *str in results) {
        if (str.length == 0 || [str isEqualToString:@"\r"]) {
            continue;
        }
        [self.contents addObject:str];
    }
    [self processContents];
}

#pragma mark - < private >
- (void)processContents {
    for (NSString *string in self.contents) {
        if ([string containsString:@"200"] && [string containsString:@"OK"]) {
            _isResponeseOk = YES;
        }
        if ([string containsString:@"{"]) {
            _responseContent = string;
        }
    }
}

- (void)reset {
    _response = nil;
    _isResponeseOk = NO;
    _responseContent = nil;
    [_contents removeAllObjects];
    _contents = nil;
}

- (BOOL)isValidResponse:(NSString *)response {
    BOOL isValid = ([response containsString:@"mode"] ||
                    [response containsString:@"sw"] ||
                    [response containsString:@"temp"] ||
                    [response containsString:@"upgrade"] ||
                    [response containsString:@"ctrl"] ||
                    [response containsString:@"act"]
                    );
    return isValid;
}

@end
