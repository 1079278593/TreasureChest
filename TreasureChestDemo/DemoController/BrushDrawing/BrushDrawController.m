//
//  BrushDrawController.m
//  TreasureChest
//
//  Created by jf on 2020/7/22.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "BrushDrawController.h"
#import "BrushDrawView.h"
#import "EllipsePointsView.h"

@interface BrushDrawController ()

@property(nonatomic, strong)BrushDrawView *drawView;
@property(nonatomic, strong)EllipsePointsView *ellipseView;

@end

@implementation BrushDrawController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bgPic"].CGImage);
    self.drawView = [[BrushDrawView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenWidth)];
//    self.drawView.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:self.drawView];
    
    CGFloat height = 200;
    //矩形
    EllipsePointsView *ellipseView = [[EllipsePointsView alloc]initWithFrame:CGRectMake(50, 164, 15, height)];
    ellipseView.layer.borderWidth = 1;
    [self.view addSubview:ellipseView];
    [ellipseView createRect:ellipseView.size];
    
    //椭圆
    EllipsePointsView *ellipseView1 = [[EllipsePointsView alloc]initWithFrame:CGRectMake(80, 164, 15, height)];
    ellipseView1.layer.borderWidth = 1;
    [self.view addSubview:ellipseView1];
    [ellipseView1 createEllipse:ellipseView1.size];
    
    //老椭圆
    EllipsePointsView *ellipseView2 = [[EllipsePointsView alloc]initWithFrame:CGRectMake(120, 164, 15, height)];
    ellipseView2.layer.borderWidth = 1;
    [self.view addSubview:ellipseView2];
    [ellipseView2 createBrushWithSize:ellipseView2.size];
}


@end
