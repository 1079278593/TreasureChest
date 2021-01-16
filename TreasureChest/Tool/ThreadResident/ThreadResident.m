//
//  ThreadResident.m
//  TreasureChest
//
//  Created by jf on 2021/1/15.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "ThreadResident.h"

@interface ThreadResident () <NSMachPortDelegate>


@end

@implementation ThreadResident

- (instancetype)init {
    if(self == [super init]){
        //1.测试线程通信：
//        [self threadCommunication];
        
        //2.调用常驻线程
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//            [self callThread];
//        });
    
        //3.调用基于信号量的常驻线程
        
    }
    return self;
}


#pragma mark - < NThread + Runloop >

- (void)callThread {
    [self performSelector:@selector(callEvent) onThread:[self runloopThread] withObject:nil waitUntilDone:NO];
}

- (void)callEvent {
    NSLog(@"调用创建的常驻线程成功，并触发事件");
}

//https://www.jianshu.com/p/426805109e88
- (NSThread *)runloopThread {
    static NSThread *thread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadEvent:) object:nil];
        [thread start];
    });
    return thread;
}

- (void)endResidentThread_Runloop:(NSMachPort *)port mode:(NSRunLoopMode)mode {
    NSLog(@"传入port以终止");
    [[NSRunLoop currentRunLoop]removePort:port forMode:mode];
}

- (void)threadEvent:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"com.ming.RunloopThread"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}


#pragma mark - < Semaphore >
//https://blog.csdn.net/weixin_33806914/article/details/88022822
- (void)startResidentThread_Semaphore {
    
}


#pragma mark - < 线程通信 >
- (void)threadCommunication {
    //声明两个端口   随便怎么写创建方法，返回的总是一个NSMachPort实例
    NSMachPort *senderPort = [[NSMachPort alloc]init];
    [[NSRunLoop currentRunLoop]addPort:senderPort forMode:NSDefaultRunLoopMode];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendMsgFromPort:senderPort];//放在其他线程
    });
    
}

- (void)sendMsgFromPort:(NSMachPort*)senderPort {
    
    NSPort *threadPort = [NSMachPort port];
    threadPort.delegate = self;
    [[NSThread currentThread] setName:@"com.ming.RunloopThread"];
//    NSThread *thread = [[NSThread alloc]init];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:threadPort forMode:NSDefaultRunLoopMode];
    
    
    NSString *s1 = @"hello";
    NSData *data = [s1 dataUsingEncoding:NSUTF8StringEncoding];

//    WS(weakSelf)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSLog(@"dasf");
        NSMutableArray *array = [NSMutableArray arrayWithArray:@[senderPort,data]];
        //过2秒向threadPort发送一条消息，第一个参数：发送时间。msgid 消息标识。
        //components，发送消息附带参数。reserved：为头部预留的字节数（从官方文档上看到的，猜测可能是类似请求头的东西...）
        [threadPort sendBeforeDate:[NSDate date] msgid:1000 components:array from:senderPort reserved:0];
//        [weakSelf endResidentThread_Runloop:threadPort mode:NSDefaultRunLoopMode];//这里调用，使得消息发送失败。
    });
    
    [runLoop run];
}

//这个NSMachPort收到消息的系统回调，注意这个参数，可以先给一个id。如果用文档里的NSPortMessage会发现无法取值
- (void)handlePortMessage:(id)message {
    NSLog(@"收到消息了，线程为：%@",[NSThread currentThread]);

    //只能用KVC的方式取值
    NSArray *array = [message valueForKeyPath:@"components"];

    NSData *data =  array[1];
    NSString *s1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",s1);

//    NSMachPort *localPort = [message valueForKeyPath:@"localPort"];
//    NSMachPort *remotePort = [message valueForKeyPath:@"remotePort"];
}
@end
