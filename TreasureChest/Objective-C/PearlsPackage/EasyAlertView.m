//
//  EasyAlertView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/3/27.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "EasyAlertView.h"

@interface EasyAlertView ()

@property(nonatomic, strong)UIButton *blackViewButton;

@end

@implementation EasyAlertView

- (instancetype)init {
    if(self == [super init]){
        [self addSubview:self.blackViewButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.blackViewButton.frame = self.bounds;
}

#pragma mark - < event >
- (void)backButtonEvent {
    [self removeFromSuperview];
}

#pragma mark - < init >
- (UIButton *)blackViewButton {
    if (_blackViewButton == nil) {
        _blackViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _blackViewButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_blackViewButton addTarget:self action:@selector(backButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_blackViewButton];
        
    }
    return _blackViewButton;
}
@end
