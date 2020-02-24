//
//  TabScrollView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "TabScrollView.h"
#import <Masonry/Masonry.h>

@interface TabScrollView()<UIScrollViewDelegate,TabTitleScrollViewDelegate>

@property(nonatomic, strong)NSArray *views;
@property(nonatomic, strong)NSArray *titles;

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
    _titleScrollView.delegate = self;
    
    _contentScrollView = [[UIScrollView alloc]init];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.frame = CGRectMake(0, titleHeght, width, height-titleHeght);
    _contentScrollView.contentSize = CGSizeMake(width*_views.count, CGRectGetHeight(_contentScrollView.frame));
    [self addSubview:_contentScrollView];
    
    [self initScrollViewContents];
    [self addSubview:_titleScrollView];
}

- (void)initScrollViewContents {
    CGFloat width = CGRectGetWidth(_contentScrollView.frame);
    CGFloat height = CGRectGetHeight(_contentScrollView.frame);
    
    for (int i = 0; i<_views.count; i++) {
        UIView *view = _views[i];
        view.frame = CGRectMake(width * i, 0, width, height);
        [_contentScrollView addSubview:view];
//        view.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.3+i*0.05];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat ratio = scrollView.contentOffset.x / scrollView.contentSize.width;
    [_titleScrollView offsetXRatio:ratio];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat ratio = scrollView.contentOffset.x / scrollView.contentSize.width;
    [_titleScrollView refreshSelectedWithRatio:ratio];
}

#pragma mark - title scrollview delegate
- (void)tabButtonSelectedIndex:(NSInteger)index {
    CGPoint offset = _contentScrollView.contentOffset;
    offset.x = index * CGRectGetWidth(_contentScrollView.frame);
    [_contentScrollView setContentOffset:offset animated:true];
}

@end
