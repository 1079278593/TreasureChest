//
//  TabTitleScrollView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "TabTitleScrollView.h"

static CGFloat buttonWidth = 95.0;
static CGFloat buttonPaddingWidth = 35.0;

@interface TabTitleScrollView()<UIScrollViewDelegate>

@property(strong, nonatomic)NSArray *titles;
@property(strong, nonatomic)NSMutableArray <UIButton *> *titleButtons;
@property(strong, nonatomic)UIScrollView *contentScrollView;

@end

@implementation TabTitleScrollView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    if(self == [super initWithFrame:frame]){
        _titles = titles;
        _titleButtons = [NSMutableArray arrayWithCapacity:0];
        [self initView];
    }
    return self;
}

- (void)initView {
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat pageWidth = buttonWidth + buttonPaddingWidth;
    
    _contentScrollView = [[UIScrollView alloc]init];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.frame = CGRectMake(0, 0, width, height);
    _contentScrollView.contentSize = CGSizeMake(pageWidth*_titles.count, CGRectGetHeight(_contentScrollView.frame));
    [self addSubview:_contentScrollView];

    [self initScrollViewContents];
}

- (void)initScrollViewContents {

    CGFloat height = CGRectGetHeight(_contentScrollView.frame);
    CGFloat pageWidth = buttonWidth + buttonPaddingWidth;
    
    for (int i = 0; i<_titles.count; i++) {
        NSString *title = _titles[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(15 + pageWidth*i, 0, buttonWidth, height);
        [_contentScrollView addSubview:button];
        button.tag = i;
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        [_titleButtons addObject:button];
    }
}

- (void)buttonEvent:(UIButton *)button {
    NSLog(@"title button tag:%ld",(long)button.tag);
}

@end
