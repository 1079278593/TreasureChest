//
//  SecondController.m
//  TreasureChest
//
//  Created by ming on 2021/4/11.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "SecondController.h"
#import <AFNetworking.h>

@interface SecondController ()

@end

@implementation SecondController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self testAfnetworking];
}

#pragma mark - < test >
- (void)testAfnetworking {
    NSDictionary *dict = @{@"abc":@"123",@"number":@3};
    NSString *result = AFQueryStringFromParameters(dict);
    
    
    int a = 3;
}


@end
