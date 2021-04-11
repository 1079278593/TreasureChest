//
//  TestView.m
//  TreasureChest
//
//  Created by jf on 2020/12/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestView.h"

@interface TestView ()

@property(nonatomic, strong)UIView *containerView;

@end

@implementation TestView

- (instancetype)init {
    if(self == [super init]){
        [self setupSubviews];
    }
    return self;
}

#pragma mark - < public >
+ (void)testMetaClass {
    NSLog(@"TestView testMetaClass");
}

#pragma mark - < init view >
- (void)setupSubviews {
    _containerView = [[UIView alloc]init];
    _containerView.layer.cornerRadius = 5;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_containerView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UIButton class]]) {
        return nil;
    }
    return view;
}

@end
