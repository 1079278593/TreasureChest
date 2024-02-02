//
//  HttpRequest.h
//  Lighting
//
//  Created by imvt on 2022/6/15.
//

#import <Foundation/Foundation.h>
#import "EasyTCPSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface HttpRequest : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, strong) HttpCommandRequestCompletionBlock completion;
@property (nonatomic) int statusCode;

- (id)initWithCommand:(NSString*)command timeout:(NSTimeInterval)timeout completion:(HttpCommandRequestCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
