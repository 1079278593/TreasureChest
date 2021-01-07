//
//  BusyLottie.m
//  TreasureChest
//
//  Created ming jf on 2021/1/6.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "BusyLottie.h"

@interface BusyLottie ()

@property(nonatomic, strong)NSMutableArray <LOTAnimationView *> *lottieViews;

@end

@implementation BusyLottie

- (instancetype)initWithUrl:(NSString *)url  {
    if(self == [super init]){
        self.url = url;
        self.lottieViews = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)dealloc
{
    self.lottieViews = nil;
}

#pragma mark - < public >
- (LOTAnimationView *)getLottieView {
    LOTAnimationView *lottieView;
    if (self.lottieViews.count < BusyLottieMaxShowCount) {
        lottieView = [[LOTAnimationView alloc] initWithContentsOfURL:[NSURL URLWithString:self.url]];
        [self.lottieViews addObject:lottieView];
    }else {
        lottieView = [self getFreeLottieView];
    }
//    NSLog(@"")
    return lottieView;
}

- (LOTAnimationView *)getFreeLottieView {
    for (LOTAnimationView *lottieView in self.lottieViews) {
        if (!lottieView.isAnimationPlaying) {
            return lottieView;
        }
    }
    return nil;
}

@end
