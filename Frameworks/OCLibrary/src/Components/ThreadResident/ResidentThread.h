//
//  ResidentThread.h
//  TreasureChest
//
//  Created by jf on 2021/1/15.
//  Copyright © 2021 xiao ming. All rights reserved.
//

/**
 dispatch_semaphore_t的使用
 https://blog.csdn.net/u012380572/article/details/81541954
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ResidentThreadDelegate <NSObject>

- (void)doActionFinish:(NSNumber *)num;

@end

@interface ResidentThread : NSObject

@property(nonatomic, weak)id<ResidentThreadDelegate> delegate;

- (void)start;
- (void)cancel;
-(void)pushAction:(NSNumber *)action;//改成具体的业务对象


- (void)debugActionAdd:(NSInteger)delta;//调试用

@end

NS_ASSUME_NONNULL_END
