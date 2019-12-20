//
//  TabScrollView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "TabScrollView.h"
#import <Masonry/Masonry.h>

@interface TabScrollView()<UIScrollViewDelegate>

@property(strong, nonatomic)NSArray *views;
@property(strong, nonatomic)NSArray *titles;

@end

@implementation TabScrollView

- (instancetype)initWithFrame:(CGRect)frame contents:(NSArray *)views titles:(NSArray *)titles {
    if(self == [super initWithFrame:frame]){
        _titles = titles;
        _views = views;
        [self initView];
    }
    return self;
}

#pragma mark - public


#pragma mark - init
- (void)initView {
    CGFloat titleHeght = 40;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    _titleScrollView = [[TabTitleScrollView alloc]initWithFrame:CGRectMake(0, 0, width, titleHeght) titles:self.titles];
    [self addSubview:_titleScrollView];
    
    _contentScrollView = [[UIScrollView alloc]init];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.frame = CGRectMake(0, titleHeght, width, height-titleHeght);
    _contentScrollView.contentSize = CGSizeMake(width*_views.count, CGRectGetHeight(_contentScrollView.frame));
    [self addSubview:_contentScrollView];
    
    [self initScrollViewContents];
}

- (void)initScrollViewContents {
    CGFloat width = CGRectGetWidth(_contentScrollView.frame);
    CGFloat height = CGRectGetHeight(_contentScrollView.frame);
    
    for (int i = 0; i<_views.count; i++) {
        UIView *view = _views[i];
        view.frame = CGRectMake(width * i, 0, width, height);
        [_contentScrollView addSubview:view];
        view.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.3+i*0.05];
    }
}

@end
