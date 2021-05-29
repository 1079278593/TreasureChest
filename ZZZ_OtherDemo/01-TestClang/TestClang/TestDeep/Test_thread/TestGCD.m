//
//  TestGCD.m
//  TestClang
//
//  Created by ming on 2020/6/3.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

#import "TestGCD.h"

@interface TestGCD () <NSPortDelegate>

@property(nonatomic, strong)NSPort *myPort;

@end

@implementation TestGCD

- (instancetype)init {
    if(self == [super init]){
        [self test_gcd];
//        [self test01];
        [self testThreadAlive];
    }
    return self;
}

#pragma mark - < public >
- (void)testPort {
    NSPort *port = [NSMachPort port];
    [self.myPort sendBeforeDate:[NSDate date] msgid:100 components:@[@1,@2] from:port reserved:0];
}

#pragma mark - < private >
- (void)test_gcd {
    /*死锁的根源是：
     *同一个”串行“队列，被嵌套使用，并且内部嵌套是”同步“执行方式(内部是”异步“不会有问题)。
     *如果是”并发“队列则都不会有问题。
    */
//    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        dispatch_sync(queue, ^{
            NSLog(@"deadlock");
        });
//        dispatch_async(serialQueue, ^{
//            NSLog(@"deadlock");
//        });
    });
}

#pragma mark - < runloop >
- (void)test01 {
//    dispatch_queue_t queue = dispatch_queue_create("TestGCD.test01", NULL);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    dispatch_async(queue, ^{
        NSLog(@"[1] 线程：%@",[NSThread currentThread]);
        // 当前线程没有开启 runloop 所以该方法是没办法执行的
        [self performSelector:@selector(performWithoutRunloop) withObject:nil afterDelay:1];
        NSLog(@"[3]");
        
        addRunLoopObserver();
        
        //如下方式就可以
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [self performSelector:@selector(performWithRunloop) withObject:nil afterDelay:0];
        NSLog(@"[3]");
        [runloop run];
    });
}

///< 线程保活 >
- (void)testThreadAlive {
    dispatch_queue_t queue = dispatch_queue_create("TestGCD.test01", NULL);
    dispatch_async(queue, ^{
        NSLog(@"[1] 线程：%@",[NSThread currentThread]);
//        NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"timer 定时任务");
//        }];
        addRunLoopObserver();
        // 当前线程没有开启 runloop 所以改方法是没办法执行的
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        
        //方式1
//        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
        
        //方式2，这里只是增加port，却没有给port发送信息。怎么证明能保活？
        NSPort *port = [NSMachPort port];
        port.delegate = self;
        [runloop addPort:port forMode:NSDefaultRunLoopMode];
        
        //用另外port给这个port发消息
        self.myPort = port;
        //150ull * NSEC_PER_SEC，150毫秒或执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            NSPort *port = [NSMachPort port];
            [self.myPort sendBeforeDate:[NSDate date] msgid:100 components:@[@1,@2] from:port reserved:0];
        });
        
        
        [runloop run];//perform之前
        
        
        [self performSelector:@selector(performWithRunloop) withObject:nil afterDelay:0];
//        [runloop run];//perform之后，如果是方式2，perform先执行再run才有用。
        
        
        NSLog(@"[3]");
        
        
    });
}

- (void)performWithoutRunloop {
    NSLog(@"[2.1] 线程：%@",[NSThread currentThread]);
}

- (void)performWithRunloop {
    NSLog(@"[2.2] 线程：%@",[NSThread currentThread]);
}

#pragma mark - < <#expression#> >
static void addRunLoopObserver() {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry: {
                NSLog(@"即将进入 runloop");
            }
                break;
            case kCFRunLoopBeforeTimers: {
                NSLog(@"定时器 timers 之前");
            }
                break;
            case kCFRunLoopBeforeSources: {
                NSLog(@"Sources 事件前");
            }
                break;
            case kCFRunLoopBeforeWaiting: {
                NSLog(@"RunLoop 即将进入休眠");
            }
                break;
            case kCFRunLoopAfterWaiting: {
                NSLog(@"RunLoop 唤醒后");
            }
                break;
            case kCFRunLoopExit: {
                NSLog(@"退出");
            }
                break;
            default:
                break;
        }
    });
      // 这里 CFRunLoopGetCurrent 创建了当前线程的 runloop 对象
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

#pragma mark - < delegate >
- (void)handlePortMessage:(NSPortMessage *)message {
    
}
@end
