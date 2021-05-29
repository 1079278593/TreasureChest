//
//  NSObject+BaseMethodSwizzling.h
//  TestClang
//
//  Created by ming on 2021/5/3.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (BaseMethodSwizzling)

+ (void)base_classMethodSwizzlingWithOriginSEL:(SEL)originSEL targetSEL:(SEL)targetSEL;
+ (void)base_instanceMethodSwizzlingWithOriginSEL:(SEL)originSEL targetSEL:(SEL)targetSEL;

@end

NS_ASSUME_NONNULL_END
