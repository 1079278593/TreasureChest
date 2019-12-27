//
//  FormsViewCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/27.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "FormsViewCtl.h"
#import "FormsView.h"
@interface FormsViewCtl ()
@property(strong, nonatomic)FormsView *formsView;
@end

@implementation FormsViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView {
    NSArray *leftTitles = @[@"1dsafdsfsdafdsfsdfsdfsdfssd111",@"2",@"3",@"4",@"5",@"6"];
    
    _formsView = [[FormsView alloc]initWithFrame:CGRectMake(0, 100, KScreenWidth, KScreenHeight - 110) leftTitles:leftTitles];
    [self.view addSubview:_formsView];
    [_formsView updateRightTitles:@[@"1",@"2",@"1dsafdsfsdafdsfsdfsdfsdfssd111dfsafsdfsdfsdfsdfsdf222",@"4",@"5"]];
}

@end
