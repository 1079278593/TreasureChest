//
//  ResidentThread.m
//  TreasureChest
//
//  Created by jf on 2021/1/15.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "ResidentThread.h"
#define ResidentThreadWaitDuration 4  //等待时间

@interface ResidentThread () {
    dispatch_semaphore_t _sem;
    int semaphoreCount;
    BOOL isNeedRefreshDirectly;   //启动强制执行,默认NO，timer到时间后，改为yes
}

@property(nonatomic, assign)BOOL cancelAction;
@property(nonatomic, strong)NSThread *thread;

@property(nonatomic, assign)NSInteger currentIndex;//初始设置为-1，
@property(nonatomic, strong)NSMutableArray <NSNumber *> *actions;

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)NSInteger countDown;

@property(nonatomic, assign)NSInteger newestIndex;//调试

@end

@implementation ResidentThread

- (instancetype)init {
    if(self == [super init]){
    }
    return self;
}

#pragma mark - < public >
- (void)start {
    _currentIndex = -1;
    semaphoreCount = 0;
    isNeedRefreshDirectly = NO;
//    _actions = [NSMutableArray arrayWithObjects:@5,@4,@8,@9,@12, nil];
    _actions = [NSMutableArray arrayWithCapacity:0];
    // 创建信号量
    _sem = dispatch_semaphore_create(semaphoreCount);
    // 创建一个新线程
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [_thread start];
}

// 终止常驻线程
- (void)cancel {
    _cancelAction = YES;
    _currentIndex = -1;
    semaphoreCount = 0;
    [_thread cancel];
    _thread = nil;
    [_actions removeAllObjects];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)pushAction:(NSNumber *)action {
    [self.actions addObject:action];
    NSLog(@"新增事件环节：0，\n");
    [self semaphoreCountAdd:YES];
}

- (void)debugActionAdd:(NSInteger)delta {
    if (_currentIndex < 0) {
        _newestIndex = _currentIndex+delta;
    }else {
        _newestIndex += delta;
    }
    NSNumber *newIndex = @(_newestIndex);
    [self.actions addObject:newIndex];
    NSLog(@"新增事件环节，当前事件总量%lu，\n",self.actions.count);
    [self semaphoreCountAdd:YES];
}

#pragma mark - < timer >
- (void)startTimer {
    if (self.timer.isValid) {
        self.countDown = ResidentThreadWaitDuration;
        return;
    }
    isNeedRefreshDirectly = NO;
    self.countDown = ResidentThreadWaitDuration;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:ResidentThreadWaitDuration target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    [self.timer fire];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (void)timerFire {
    NSLog(@"timerFire loop");
    if (self.countDown <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        isNeedRefreshDirectly = YES;
        NSLog(@"timerFire 时间到");
        return;
    }
    self.countDown -= ResidentThreadWaitDuration;
}

#pragma mark - < run >
- (void)run {
    while (true) {
        if(_cancelAction){
            break;// 如果线程已经取消了，那么退出循环。这里如果需要，发送结束完成的信号出去。
        }
        NSLog(@"等待 进入信号环节：1，\n");
        //初始信号量如果为0，dispatch_semaphore_wait后，变成-1等待，来了个信号后变成0(不小于0就可以往下执行)，往下执行。
        [self semaphoreCountAdd:NO];
        [self doAction];
    }
}

// 执行任务
- (void)doAction {
    NSLog(@"事件数量：%lu，%@",self.actions.count,self.actions);
    if (self.actions.count <= 0) {
        NSLog(@"进入无数据环节：3，");
        return;
    }
    
    //1.找到最小序列
    int minIndex = [self getMinIndex:self.actions];
    NSNumber *minIndexAction = self.actions[minIndex];
    
    //2. 判断是否执行等各种情况。后台指令一定大于0.
    if (_currentIndex == -1 || minIndexAction.intValue == _currentIndex+1) {//’初始指令‘或者’最合适‘的指令，立马执行
        NSLog(@"最合适的指令,执行:%d",minIndexAction.intValue);
        _currentIndex = minIndexAction.intValue;
        [self actionWillDo:minIndexAction];
        isNeedRefreshDirectly = NO;//这个决定：’跳级指令‘是否重新等待一定时间。
    }else if (minIndexAction.intValue <= _currentIndex) {
        NSLog(@"不执行，废弃指令：%d",minIndexAction.intValue);
        [self actionWillDo:minIndexAction];
    }else if (minIndexAction.intValue > _currentIndex+1) {
        if (isNeedRefreshDirectly) {
            NSLog(@"等待超时，执行:%d",minIndexAction.intValue);
            _currentIndex = minIndexAction.intValue;
            [self actionWillDo:minIndexAction];
            isNeedRefreshDirectly = NO;
        }else {
            NSLog(@"等待，并开启timer");
            [self startTimer];
        }
    }else {
        NSLog(@"其它");//前面基本都能命中，这里应该不需要。改成bugly输出
    }
}

#pragma mark - < private >
- (void)actionWillDo:(NSNumber *)action {
    [_actions removeObject:action];
    if (_actions.count > 0) {//如果还有数据就恢复信号量
        [self semaphoreCountAdd:YES];
    }
}
///dispatch_semaphore_wait是进行信号量减1操作，而dispatch_semaphore_signal是进行加1操作。
- (void)semaphoreCountAdd:(BOOL)isAdd {
    if (isAdd) {
        if (semaphoreCount < 1) {
            NSLog(@"增加信号量");
            dispatch_semaphore_signal(_sem);
            semaphoreCount++;
        }
    }else {
        //等待信号量：对semaphore减一，如果值小于0（注意是小于0），则等待，如果不小于0，则执行code处代码
        dispatch_semaphore_wait(_sem, [self waitDuration]);//等待一段时间，超时后就会进入执行
        semaphoreCount--;
    }
}

- (void)nextRunloop {
    
}

- (dispatch_time_t)waitDuration {
    BOOL isNotEmpty = _actions.count > 0;
    if (isNotEmpty) {
        return dispatch_time(DISPATCH_TIME_NOW, ResidentThreadWaitDuration * NSEC_PER_SEC);
    }
    return DISPATCH_TIME_FOREVER;
}

//这里不判断越界，调用时要注意
- (int)getMinIndex:(NSMutableArray <NSNumber *> *)actions {
    int arrayIndex = 0;
    NSInteger minActionIndex = NSIntegerMax;
    for (int i = 0; i<actions.count; i++) {
        NSInteger index = actions[i].integerValue;
        if (index < minActionIndex) {
            minActionIndex = index;
            arrayIndex = i;
        }
    }
    return arrayIndex;
}

@end
