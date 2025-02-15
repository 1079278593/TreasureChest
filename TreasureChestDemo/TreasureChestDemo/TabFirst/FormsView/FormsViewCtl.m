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
@property(nonatomic, strong)FormsView *formsView;
@end

@implementation FormsViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubviews];
}

- (void)setupSubviews {
    NSArray *leftTitles = @[@"1dsafdsfsdafdsfsdfsdfsdfssd111",@"2",@"3",@"4",@"5",@"6"];
    
    _formsView = [[FormsView alloc]initWithFrame:CGRectMake(0, 100, KScreenWidth, KScreenHeight - 110) count:leftTitles.count];
    [self.view addSubview:_formsView];
    [_formsView updateLeftTitles:leftTitles];
    [_formsView updateRightTitles:@[@"1",@"2",@"1dsafdsfsdafdsfsdfsdfsdfssd111dfsafsdfsdfsdfsdfsdf222",@"4",@"5"]];
}

@end
