//
//  SocketHttpsController.m
//  TreasureChest
//
//  Created by imvt on 2024/1/24.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import "SocketHttpsController.h"
#import "RequestQueue.h"
#import "Request.h"

@interface SocketHttpsController ()

@property(nonatomic, strong)NSString *ip;
@property(nonatomic, strong)RequestQueue *requestQueue;
@property(nonatomic, strong)NSString *userDefalutsCookie;///一般存到沙盒，这里是方便使用

@end

@implementation SocketHttpsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubViews];
//    self.ip = @"192.168.31.248";//imvt24
    self.ip = @"192.168.31.231";//imvt24(digest)
//    self.ip = @"192.168.9.138";//imvt25
    self.requestQueue = [[RequestQueue alloc]initWithIP:self.ip andPort:443];
    
//    self.requestQueue = [[RequestQueue alloc]initWithIP:@"192.168.31.248" andPort:80];
}

#pragma mark - < event >
- (void)basicEvent:(UIButton *)button {
    Request *request = [[Request alloc]initWithIp:self.ip headerType:AuthHeaderTypeBasic];
    [request prepareWithName:@"admin" password:@"admin12345678" www_auth:@""];
    [request requestWithCmd:@"/login/" timeout:10];
    
    WS(weakSelf)
    [self.requestQueue request:request completion:^(NSError *error, HttpResponseHeader *header, NSData *data) {
        if ([header.location containsString:@"www/index.html"] && header.statusCode == 302) {//登录成功，拿cookie
            //存储cookie
            weakSelf.userDefalutsCookie = [header.cookie copy];
        }
    }];
}
- (void)basicGetEvent:(UIButton *)button {
    Request *request = [[Request alloc]initWithIp:self.ip headerType:AuthHeaderTypeCookie];
    [request prepareWithCookie:self.userDefalutsCookie];
    [request requestWithCmd:@"/ctrl/get?k=saturation" timeout:10];
    
    WS(weakSelf)
    [self.requestQueue request:request completion:^(NSError *error, HttpResponseHeader *header, NSData *data) {
        NSError *error1 = nil;
        if (data) {
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error1];
            NSLog(@"请求%@ ：%@",request.cmd,json);
        }
    }];
}

- (void)digestEvent:(UIButton *)button {
    Request *request = [[Request alloc]initWithIp:self.ip headerType:AuthHeaderTypeDefault];
    [request requestWithCmd:@"/ctrl/session" timeout:10];
//    [request requestWithCmd:@"/login/" timeout:10];
    
    WS(weakSelf)
    [self.requestQueue request:request completion:^(NSError *error, HttpResponseHeader *header, NSData *data) {
        Request *request1 = [[Request alloc]initWithIp:weakSelf.ip headerType:AuthHeaderTypeDigest];
        [request1 prepareWithName:@"admin" password:@"Admin_123" www_auth:header.www_authenticate];
        [request1 requestWithCmd:@"/login/" timeout:10];
        
        [weakSelf.requestQueue request:request1 completion:^(NSError *error, HttpResponseHeader *header, NSData *data) {
            //登录成功，拿cookie
            if ([header.location containsString:@"www/index.html"] && header.statusCode == 302) {
                //存储cookie
                weakSelf.userDefalutsCookie = [header.cookie copy];
            }else if (header.statusCode == 401) {
                Request *request1 = [[Request alloc]initWithIp:weakSelf.ip headerType:AuthHeaderTypeDigest];
                [request1 prepareWithName:@"admin" password:@"Admin_123" www_auth:header.www_authenticate];
                [request1 requestWithCmd:@"/login/" timeout:10];
                
                [weakSelf.requestQueue request:request1 completion:^(NSError *error, HttpResponseHeader *header, NSData *data) {
                    //登录成功，拿cookie
                    if ([header.location containsString:@"www/index.html"] && header.statusCode == 302) {
                        //存储cookie
                        weakSelf.userDefalutsCookie = [header.cookie copy];
                    }
                }];
            }
        }];
    }];
}

- (void)digestGetEvent:(UIButton *)button {
    [self basicGetEvent:nil];
}

#pragma mark - < setup >
- (void)setupSubViews {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"basic" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    button.frame = CGRectMake(70, 100, 90, 45);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(basicEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"basicGet" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor lightGrayColor];
    button1.frame = CGRectMake(70, 170, 90, 45);
    [self.view addSubview:button1];
    [button1 addTarget:self action:@selector(basicGetEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"digest" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor lightGrayColor];
    button2.frame = CGRectMake(170, 100, 90, 45);
    [self.view addSubview:button2];
    [button2 addTarget:self action:@selector(digestEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setTitle:@"digestGet" forState:UIControlStateNormal];
    button3.backgroundColor = [UIColor lightGrayColor];
    button3.frame = CGRectMake(170, 170, 90, 45);
    [self.view addSubview:button3];
    [button3 addTarget:self action:@selector(digestGetEvent:) forControlEvents:UIControlEventTouchUpInside];
    
}

@end
