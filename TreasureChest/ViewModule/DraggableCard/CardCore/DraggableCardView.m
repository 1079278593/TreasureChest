//
//  DraggableCardView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "DraggableCardView.h"

@implementation DraggableCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultStyle];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultStyle];
    }
    return self;
}

- (void)awakeFromNib {
    [self defaultStyle];
}

- (void)defaultStyle {
    self.userInteractionEnabled = YES;
    // [self.subviews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor whiteColor]];
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:10.0f];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    CGFloat scaleBackgroud = 245.0f / 255.0f;
    self.backgroundColor = [UIColor colorWithRed:scaleBackgroud green:scaleBackgroud blue:scaleBackgroud alpha:1];
    
    CGFloat scaleBorder = 176.0f / 255.0f;
    [self.layer setBorderWidth:.45];
    [self.layer setBorderColor:[UIColor colorWithRed:scaleBorder green:scaleBorder blue:scaleBorder alpha:1].CGColor];
}

- (void)cc_layoutSubviews {}

@end
