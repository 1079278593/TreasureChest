//
//  ThirdController.m
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import "ThirdController.h"
#import "ControllerTableView.h"

@interface ThirdController ()

@end

@implementation ThirdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setupSubViews];
}

- (void)willResignActiveNotification {
    NSLog(@"myprint: active willResignActiveNotification");
}

- (void)didBecomeActiveNotification {
    NSLog(@"myprint: active didBecomeActiveNotification");
}

#pragma mark - < init view >
- (void)setupSubViews {
    ControllerTableView *tableView = [[ControllerTableView alloc]init];
    [self.view addSubview:tableView];
    tableView.frame = CGRectMake(0, 64, KScreenWidth, KScreenHeight-64);
    
    [tableView showWithTabType:TabType_third];
}

@end
