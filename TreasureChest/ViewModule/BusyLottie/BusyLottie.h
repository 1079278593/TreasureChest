//
//  BusyLottie.h
//  TreasureChest
//
//  Created ming jf on 2021/1/6.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lottie.h"

#define BusyLottieMaxShowCount 3    //最大同时显示数量

NS_ASSUME_NONNULL_BEGIN

@interface BusyLottie : NSObject

@property(nonatomic, strong)NSString *url;

- (instancetype)initWithUrl:(NSString *)url;
- (LOTAnimationView *)getLottieView;

@end

NS_ASSUME_NONNULL_END
