//
//  BrushDrawController.m
//  TreasureChest
//
//  Created by jf on 2020/7/22.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "BrushDrawController.h"
#import "BrushDrawView.h"

@interface BrushDrawController ()

@property(nonatomic, strong)BrushDrawView *drawView;

@end

@implementation BrushDrawController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bgPic"].CGImage);
    self.drawView = [[BrushDrawView alloc]initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenWidth)];
//    self.drawView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.drawView];
    
    
}


@end
