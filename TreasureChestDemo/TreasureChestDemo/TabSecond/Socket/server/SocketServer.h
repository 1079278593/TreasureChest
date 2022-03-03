//
//  SocketServer.h
//  TreasureChest
//
//  Created by imvt on 2022/3/1.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SocketServer;

NS_ASSUME_NONNULL_BEGIN

@protocol SocketServerDelegate <NSObject>

- (BOOL)server:(SocketServer *)server prepareMsg:(NSString *)message;
- (void)server:(SocketServer *)server receiveMsg:(NSString *)message;

@end


//if ([self.delegate respondsToSelector:@selector(<#method#>)]) {
//    [self.delegate <#method#>];
//}

@interface SocketServer : NSObject

@property(nonatomic, weak)id<SocketServerDelegate> delegate;

- (void)startServer;
- (void)sendMessage:(NSString *)content;
- (void)closeServer;

@end

NS_ASSUME_NONNULL_END
