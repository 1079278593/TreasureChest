//
//  DelayTimer.m
//  Lighting
//
//  Created by imvt on 2022/11/18.
//

#import "DelayTimer.h"
#import "MSWeakTimer.h"

#define KTimeInterval 0.1

@interface DelayTimer ()

@property (nonatomic, copy) TimeoutBlock block;

@property(nonatomic, strong)MSWeakTimer *timer;
@property(nonatomic, assign)CGFloat countDown;

@end

@implementation DelayTimer

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - < public >
- (void)startTimeWithDelay:(CGFloat)delay block:(void (^) (void))timeoutBlock {
    self.block = timeoutBlock;
    self.countDown = delay;
    [self startTimer];
}

#pragma mark - < timer >
- (void)startTimer {
    if (self.timer) {
        return;
    }
    [self.timer invalidate];
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:KTimeInterval target:self selector:@selector(timerFire) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
}

- (void)timerFire {
    if (self.countDown <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        self.block();//回调
        return;
    }
    self.countDown -= KTimeInterval;
}

@end
