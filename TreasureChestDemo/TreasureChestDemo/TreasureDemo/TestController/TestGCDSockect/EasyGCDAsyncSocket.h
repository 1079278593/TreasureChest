//
//  EasyGCDAsyncSocket.h
//  TreasureChest
//
//  Created by imvt on 2022/2/17.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasyGCDAsyncSocket : NSObject

- (void)connectWithHost:(NSString *)host port:(NSUInteger)port;
- (void)reconnect;
- (void)disconnect;
- (void)socketRequestWithDict:(NSDictionary *)dict path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
