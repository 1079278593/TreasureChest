//
//  ViewController.m
//  TestClang
//
//  Created by ming on 2020/6/2.
//  Copyright © 2020 雏虎科技. All rights reserved.
//

#import "ViewController.h"

#import "TestDeep.h"
#import "TestRender.h"

#define KRandomColor(a) [UIColor colorWithRed:(arc4random() % 256)/255.0 green:(arc4random() % 256)/255.0 blue:(arc4random() % 256)/255.0 alpha:a]

@interface ViewController ()

@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIButton *button1;
@property(nonatomic, strong)TestDeep *testDeep;
@property(nonatomic, strong)TestRender *testRender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.testRender.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)/2.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/2.0);
    self.testRender.backgroundColor = KRandomColor(0.4);
    [self.view addSubview:self.testRender];
    
    [self setupSubViews];
}
- (void)displayLayer:(CALayer *)layer {
    layer.backgroundColor = [UIColor cyanColor].CGColor;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    layer.backgroundColor = [UIColor orangeColor].CGColor;
}
#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    [self.testDeep testDeepMethod1];
}

- (void)buttonEvent1:(UIButton *)button {
    [self.testDeep testDeepMethod2];
}

#pragma mark - < init view >
- (void)setupSubViews {
    self.button.frame = CGRectMake(100, 100, 80, 45);
    [self.view addSubview:self.button];
    
    self.button1.frame = CGRectMake(100, 170, 80, 45);
    [self.view addSubview:self.button1];
    
//    [self buttonEvent:nil];
}

#pragma mark - < getter >
- (UIButton *)button {
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"按钮1" forState:UIControlStateNormal];
        [_button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }
    return _button;
}

- (UIButton *)button1 {
    if (_button1 == nil) {
        _button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button1 setTitle:@"按钮2" forState:UIControlStateNormal];
        [_button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_button1 addTarget:self action:@selector(buttonEvent1:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button1];
    }
    return _button1;
}

- (TestDeep *)testDeep {
    if (_testDeep == nil) {
        _testDeep = [[TestDeep alloc]init];
    }
    return _testDeep;
}

- (TestRender *)testRender {
    if (_testRender == nil) {
        _testRender = [[TestRender alloc]init];
    }
    return _testRender;
}

@end
