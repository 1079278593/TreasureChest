//
//  BaseShapeView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/4.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "BaseShapeView.h"

@implementation BaseShapeView

- (instancetype)init {
    if(self == [super init]){
        _lineWidth = 4;
        _strokeColor = [UIColor grayColor];
    }
    return self;
}


@end
