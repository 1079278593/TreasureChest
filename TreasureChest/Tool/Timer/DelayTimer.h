//
//  DelayTimer.h
//  Lighting
//
//  Created by imvt on 2022/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TimeoutBlock)(void);

@interface DelayTimer : NSObject

- (void)startTimeWithDelay:(CGFloat)delay block:(TimeoutBlock)timeoutBlock;

@end

NS_ASSUME_NONNULL_END
