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

@property(nonatomic, strong)UIImageView *containerView;

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
    NSLog(@"touch began");
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch move");
}
#pragma mark - < init view >
- (void)setupSubviews {
    _containerView = [[UIImageView alloc]init];
    [self addSubview:_containerView];
    _containerView.layer.borderWidth = 1;
    _containerView.layer.borderColor = [UIColor redColor].CGColor;
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        int padding = 0;
        make.edges.mas_equalTo(UIEdgeInsetsMake(padding, padding, padding, padding));
    }];
    _containerView.image = [UIImage imageNamed:@"hsiWheelColorSpec"];
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if ([view isKindOfClass:[UIButton class]]) {
//        return nil;
//    }
//    return view;
//}

@end
