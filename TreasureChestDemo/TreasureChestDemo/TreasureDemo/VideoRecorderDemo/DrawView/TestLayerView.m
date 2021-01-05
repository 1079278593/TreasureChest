//
//  TestLayerView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/18.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestLayerView.h"
#import "TestActionKeyLayer.h"
#import "TestGradientLayer.h"

@interface TestLayerView ()

@property(nonatomic, strong)TestActionKeyLayer *circularProgress;
@property(nonatomic, strong)CALayer *colorLayer;

@end

@implementation TestLayerView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self colorAnimationStart];
}

- (void)initView {
//    [self showProgressView];
    [self showColorTransition];
}

- (void)showProgressView {
    TestGradientLayer *gradientLayer = [[TestGradientLayer alloc]init];
    gradientLayer.frame = CGRectMake(100, 10, 200, 200);
    [self.layer addSublayer:gradientLayer];
    
    TestGradientLayer *gradientLayer1 = [[TestGradientLayer alloc]init];
    gradientLayer1.frame = CGRectMake(100, 220, 200, 200);
    [self.layer addSublayer:gradientLayer1];
    
    self.circularProgress = [[TestActionKeyLayer alloc] initWithFrame:gradientLayer.bounds];
    gradientLayer1.mask = self.circularProgress;
    self.circularProgress.arcLenght = 50;
}

- (void)showColorTransition {
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(100.0f, 300.0f, 100.0f, 100.0f);
    self.colorLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:self.colorLayer];
    

    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    transition.duration =3;
    self.colorLayer.actions = @{@"backgroundColor": transition};
    //layer在style字典中去寻找（style字典中有一个actions的key，其value为一个字典，layer就是在这个字典中去寻找key对应的action object）
//    self.colorLayer.style = @{@"actions": @{@"backgroundColor": transition}};
}

- (void)colorAnimationStart {
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
}



@end
