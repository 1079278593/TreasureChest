//
//  InterpolateGenerator.h
//  TestClang
//
//  Created by ming on 2021/4/12.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InterpolateGenerator : NSObject

//float interpolate(float from, float to, float time);
+ (id)interpolateFromValue:(id)fromValue toValue:(id)toValue time:(float)time;
float bounceEaseOut(float t);

@end

NS_ASSUME_NONNULL_END
