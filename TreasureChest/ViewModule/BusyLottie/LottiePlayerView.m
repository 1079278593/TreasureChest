//
//  LottiePlayerView.m
//  TreasureChest
//
//  Created by ming on 2021/1/6.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "LottiePlayerView.h"
#import "BusyLottie.h"

@interface LottiePlayerView ()

@property(nonatomic, strong)NSMutableArray <BusyLottie *> *lottieViews;

@end

@implementation LottiePlayerView

- (instancetype)init {
    if(self == [super init]){
        self.lottieViews = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)dealloc
{
    self.lottieViews = nil;
}

#pragma mark - < public >
- (void)showLottieWithUrl:(NSString *)url {
    BusyLottie *busyLottie = [self getBusyLottie:url];
    if (busyLottie == nil) {
        busyLottie = [[BusyLottie alloc]initWithUrl:url];
        [self.lottieViews addObject:busyLottie];
    }
    LOTAnimationView *lottieView = [busyLottie getLottieView];
    if (lottieView == nil) {
        return;
    }
    
    lottieView.frame = CGRectMake(30, 100, 200, 200);
    [self addSubview:lottieView];
    
    [lottieView play];
    __weak LOTAnimationView *blockLottie1 = lottieView;
    lottieView.completionBlock = ^(BOOL animationFinished) {
        [blockLottie1 removeFromSuperview];
        NSLog(@"lottie remove");
    };
}

#pragma mark - < private >
- (BusyLottie *)getBusyLottie:(NSString *)url {
    for (BusyLottie *lottie in self.lottieViews) {
        if ([lottie.url isEqualToString:url]) {
            return lottie;
        }
    }
    return nil;
}

@end
