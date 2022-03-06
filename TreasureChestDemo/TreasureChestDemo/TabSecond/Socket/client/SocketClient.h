//
//  SocketClient.h
//  TreasureChest
//
//  Created by imvt on 2022/3/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SocketClient;

NS_ASSUME_NONNULL_BEGIN

@protocol SocketClientDelegate <NSObject>

- (void)client:(SocketClient *)client prepareMsg:(NSString *)message;
- (void)client:(SocketClient *)client receiveMsg:(NSString *)message;

@end


//if ([self.delegate respondsToSelector:@selector(<#method#>)]) {
//    [self.delegate <#method#>];
//}

@interface SocketClient : NSObject

@property(nonatomic, weak)id<SocketClientDelegate> delegate;

- (void)startClient;
- (void)sendMessage:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
