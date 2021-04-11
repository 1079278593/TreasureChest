//
//  TestGradientLayer.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/18.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "TestGradientLayer.h"

@interface TestGradientLayer ()


@end

@implementation TestGradientLayer

- (instancetype)init {
    if(self == [super init]){
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    NSArray * colors = @[(id)[[UIColor hexColor:@"0xFF6347"] CGColor],
                         (id)[[UIColor hexColor:@"0xFFEC8B"] CGColor],
                         (id)[[UIColor hexColor:@"0x98FB98"] CGColor],
                         (id)[[UIColor hexColor:@"0x00B2EE"] CGColor],
                         (id)[[UIColor hexColor:@"0x9400D3"] CGColor]];
    NSArray * locations = @[@0.1,@0.3,@0.5,@0.7,@1];
    
    self.colors = colors;
    self.locations = locations;
    self.startPoint = CGPointMake(0, 0);
    self.endPoint = CGPointMake(1, 0);
}

@end
