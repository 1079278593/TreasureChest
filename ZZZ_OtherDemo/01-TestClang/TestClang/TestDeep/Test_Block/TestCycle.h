//
//  TestCycle.h
//  TestClang
//
//  Created by ming on 2021/5/20.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlockStudy)(void);

@interface TestCycle : NSObject

@property (copy , nonatomic) NSString *name;
@property (copy , nonatomic) BlockStudy blockStudy;

@end

NS_ASSUME_NONNULL_END
