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
#import <OAStackView.h>

@interface ShapeViewCtl ()

@property(nonatomic, strong)XMCircleView *circleView;

@property(nonatomic, strong)UIStackView *stackView;

@end

@implementation ShapeViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    self.stackView.frame = CGRectMake(0, 400, KScreenWidth, 100);
    
}

- (void)initView {
    _circleView = [[XMCircleView alloc]init];
    _circleView.layer.borderWidth = 1;
    _circleView.frame = CGRectMake(10, 70, 200, 200);
    [self.view addSubview:_circleView];
    
    XMDashLineView *dashLine = [[XMDashLineView alloc]init];
    dashLine.frame = CGRectMake(10, _circleView.bottom + 50, KScreenWidth - 20, 3);
    dashLine.lengthArray = @[@24,@15,@3];
    [self.view addSubview:dashLine];
    
    UISlider *slieder = [[UISlider alloc]init];
    slieder.value = 0;
    slieder.frame = CGRectMake(40, KScreenHeight - 100, KScreenWidth - 80, 30);
    [self.view addSubview:slieder];
    [slieder addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChange:(UISlider *)slider {
    _circleView.lineWidth = 4 + slider.value * 20;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.circleView.strokeColor = [UIColor redColor];
    
    [self showStackView];

}

#pragma mark - < tmp >
- (void)showStackView {
    UIView *redView = [[UIView alloc]init];
    redView.frame = CGRectMake(0, 0, 100, 100);
    redView.backgroundColor = [UIColor redColor];

    [self.stackView addArrangedSubview:redView];
}

//
/*
 * 简单：https://www.jianshu.com/p/8270db45cfa1
 * 深入：https://www.cnblogs.com/breezemist/p/5776552.html
 * 怎么用storyBoard：https://www.hangge.com/blog/cache/detail_1750.html
 * storyBoard入门：https://www.jianshu.com/p/26c4bd1d9147
 
 Axis表示Stack View的subview是水平排布还是垂直排布。

 Alignment控制subview对齐方式。alignment 属性指定了子视图在布局方向上的对齐方式，如果值是 Fill 则会调整子视图以适应空间变化，其他的值不会改变视图的大小。有效的值包含：Fill、 Leading、 Top、 FirstBaseline、 Center、 Trailing、 Bottom、 LastBaseline。

 Distribution 分布：定义了 subviews 的分布方式，可以赋值的5个枚举值可以分为两组： Fill 组 和 Spacing 组。
 Fill 组用来调整 subviews 的大小，同时结合 spacing 属性来确定 subviews 之间的间距。

 subView和arrangedSubView

 开始使用Stack View前，我们先看一下它的属性subViews和arrangedSubvies属性的不同。
 -->arrangedSubviews数组是subviews属性的子集。

 如果你想添加一个subview给Stack View管理，你应该调用addArrangedSubview:或insertArrangedSubview:atIndex:

 要移除Stack View管理的subview，需要调用removeArrangedSubview:和removeFromSuperview。

 移除arrangedSubview只是确保Stack View不再管理其约束，而非从视图层次结构中删除，理解这一点非常重要。
 
 */
- (UIStackView *)stackView {
    if (_stackView == nil) {
        _stackView = [UIStackView new];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.alignment = UIStackViewAlignmentFill;
        _stackView.spacing = 10;
//        _stackView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 20);
        [self.view addSubview:_stackView];
    }
    return _stackView;
}

@end
