//
//  PearlsPackageCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/25.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "PearlsPackageCtl.h"
#import "UIButton+Extension.h"
#import "XMLabel.h"

@interface PearlsPackageCtl ()

@end

@implementation PearlsPackageCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self testButtonExtension];
    
    XMLabel *label = [[XMLabel alloc]init];
    label.layer.borderWidth = 1;
    label.text = @"fdsafsdf";
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(220, 260, 100, 100);
    label.textAlignment = NSTextAlignmentRight;
    label.verticalAlignment = VerticalAlignmentBottom;
    [self.view addSubview:label];
}


#pragma mark - < 测试UIButton+Extension >
- (void)testButtonExtension {
    //正常
    UIButton *button0 = [self getButton];
    button0.frame = CGRectMake(20, 100, 160, 40);
    [self.view addSubview:button0];
    
    //图片在左
    UIButton *button1 = [self getButton];
    button1.frame = CGRectMake(20, 150, 160, 40);
    [self.view addSubview:button1];
    [button1 imageLayout:ImageLayoutLeft centerPadding:10];
    
    //图片在右
    UIButton *button2 = [self getButton];
    button2.frame = CGRectMake(20, 200, 160, 40);
    [self.view addSubview:button2];
    [button2 imageLayout:ImageLayoutRight centerPadding:10];
    
    //图片在上
    UIButton *button3 = [self getButton];
    button3.frame = CGRectMake(20, 250, 160, 80);
    [self.view addSubview:button3];
    [button3 imageLayout:ImageLayoutTop centerPadding:10];
    
    //图片在下
    UIButton *button4 = [self getButton];
    button4.frame = CGRectMake(20, 350, 160, 80);
    [self.view addSubview:button4];
    [button4 imageLayout:ImageLayoutBottom centerPadding:10];
    
//    button1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    button2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    button3.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
//    button4.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
//    
//    button1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    button2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    button3.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
//    button4.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
}

- (UIButton *)getButton {
    UIButton *button = [[UIButton alloc]init];
    button.layer.borderWidth = 1;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"options_selected_icon"] forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"testIcon1"] forState:UIControlStateNormal];//过大图片
    [button setTitle:@"t范德萨" forState:UIControlStateNormal];
    return button;
}

@end
