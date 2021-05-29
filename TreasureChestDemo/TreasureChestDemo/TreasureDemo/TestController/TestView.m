//
//  TestView.m
//  TreasureChest
//
//  Created by jf on 2020/12/25.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestView.h"
#import "TestSubView.h"

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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}
#pragma mark - < init view >
- (void)setupSubviews {
    TestSubView *testSubView = [[TestSubView alloc]init];
    testSubView.frame = CGRectMake(0, 0, 50, 50);
    [self addSubview:testSubView];
    testSubView.layer.borderWidth = 1;
    testSubView.layer.borderColor = [UIColor redColor].CGColor;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if ([view isKindOfClass:[UIButton class]]) {
//        return nil;
//    }
//    return view;
//}

@end
