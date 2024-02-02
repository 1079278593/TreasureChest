//
//  ViewController.m
//  TestSpeedDemo
//
//  Created by imvt on 2023/7/11.
//

#import "ViewController.h"

#import "ICamController.h"
#import "ICamServer.h"
#import "ICamTcpRelay.h"

#import "EasySocketQueuesManager.h"
#import <Aspects/Aspects.h>

@interface ViewController () <ICamControllerDelegate>

@property(nonatomic, strong)ICamController *iCamController;
@property(nonatomic, strong)HttpRequestQueue *commandQueue;

@property(nonatomic, strong)UIButton *prepareBtn;
@property(nonatomic, strong)UIButton *startBtn;

@property(nonatomic, assign)long long sumA ;//用于统计a的数量
@property(nonatomic, assign)int loop;//5秒一次loop，
@property(nonatomic, assign)long loopA;//5秒一次loop，

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];

    [self hookICamServer];
}

- (void)hookICamServer {
    [ICamServer aspect_hookSelector:@selector(handleTransportData:from:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, NSData *data, unsigned int channelId){
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (json == nil) {
            if (data.length >= 65535) {
                self.loopA += data.length;//a的数量
            }
        }
    } error:NULL];
    
    [ICamController aspect_hookSelector:@selector(closeConnection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, ICamTcpRelayConnection *conn){
        [self testSpeedEnd];
        NSLog(@"速率 5秒统计结束");
    } error:NULL];
}

#pragma mark - < event >
- (void)prepareBtnEvent:(UIButton *)button {
    [self setupICamController];
    //用来测试tspeed
    [self.iCamController setDelegate:self];
    [self.iCamController resume];
    NSLog(@"tspeed start icam");
}

- (void)startBtnEvent:(UIButton *)button {
    [self test];
}

- (void)test {
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self request];
    }];
}

- (void)request {
    NSUInteger port1 = 8080;//http server proxy(tspeed和info等，都是这个端口
    NSUInteger port2 = 9081;//web socket server proxy
    NSUInteger port3 = 8989;//camera server
    NSString *url1 = @"/info";
    NSString *url2 = @"/ctrl/session";
    NSString *url3 = @"/tspeed";
    HttpRequestQueue *queue = [[EasySocketQueuesManager shareInstance] connectWithHost:@"localhost" port:port1];
    [queue request:url3 params:nil timeout:5 completion:^(NSError *error, int statusCode, NSData *data) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (json) {
            int a = 3;
            a = 543;
        }else {
            NSLog(@"外界：%lu",(unsigned long)data.length);
        }
    }];
}

///超时，关闭socket时，统计数量，或者打印
- (void)testSpeedEnd {
    self.sumA += self.loopA;
    NSLog(@"a的总数：%lld，第%d的loop数%ld",self.sumA,self.loop,self.loopA);
    long count = (self.sumA/(self.loop+1)/5);
    CGFloat byteCount = count * 8.0 / 1024.0 / 1024.0;
    NSLog(@"a数量速率：%ld(个a)/s ,数据速率%fMb", count,byteCount );
    self.loopA = 0;
    self.loop++;
}

#pragma mark - < tspeed >
- (void)setupICamController {
    self.iCamController = [[ICamController alloc] init];
    [self.iCamController setDelegate:self];
}

#pragma mark - ICamControllerDelegate
- (void)iCamControllerDidConnectedClent {
    int a = 1;
    NSLog(@"tspeed iCamControllerDidConnectedClent");
}

- (void)iCamControllerDidDisconnectedClent {
    int a = 1;
    NSLog(@"tspeed iCamControllerDidDisconnectedClent");
}

- (void)setupSubViews {
    _prepareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _prepareBtn.frame = CGRectMake(60, 100, 80, 44);
    [_prepareBtn setTitle:@"prepare" forState:UIControlStateNormal];
    [_prepareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_prepareBtn addTarget:self action:@selector(prepareBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_prepareBtn];

    _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _startBtn.frame = CGRectMake(160, 100, 80, 44);
    [_startBtn setTitle:@"start" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startBtn];

}
@end
