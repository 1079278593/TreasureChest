//
//  ShapeViewCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "ShapeViewCtl.h"
#import "XMCircleView.h"
#import "XMDashLineView.h"

@interface ShapeViewCtl ()

@property(strong, nonatomic)XMCircleView *circleView;

@end

@implementation ShapeViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    UISlider *slieder = [[UISlider alloc]init];
    slieder.value = 0;
    slieder.frame = CGRectMake(40, KScreenHeight - 100, KScreenWidth - 80, 30);
    [self.view addSubview:slieder];
    [slieder addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)initView {
    _circleView = [[XMCircleView alloc]init];
    _circleView.layer.borderWidth = 1;
    _circleView.frame = CGRectMake(10, 70, 200, 200);
    [self.view addSubview:_circleView];
    
    XMDashLineView *dashLine = [[XMDashLineView alloc]init];
    dashLine.frame = CGRectMake(10, _circleView.bottom + 50, KScreenWidth - 20, 3);
    dashLine.lengthArray = @[@24,@15,@3,@8];
    [self.view addSubview:dashLine];
}

- (void)sliderValueChange:(UISlider *)slider {
    _circleView.lineWidth = 4 + slider.value * 20;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.circleView.strokeColor = [UIColor redColor];
}
@end
