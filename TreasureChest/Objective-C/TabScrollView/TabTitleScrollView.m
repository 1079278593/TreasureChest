//
//  TabTitleScrollView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "TabTitleScrollView.h"

static NSInteger maxCount = 4;
static NSString *backgroudColorString = @"007AFF";
static NSString *cursorViewColorString = @"ffffff";

@interface TabTitleScrollView()<UIScrollViewDelegate>

@property(strong, nonatomic)NSArray *titles;
@property(strong, nonatomic)NSMutableArray <UIButton *> *titleButtons;
@property(strong, nonatomic)UIScrollView *contentScrollView;
@property(strong, nonatomic)UIView *cursorLineView;
@property(assign, nonatomic)CGFloat cursorOffsetX;
@property(assign, nonatomic)CGFloat buttonWidth;

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
    self.backgroundColor = [UIColor hexColor:backgroudColorString];
    [self initScrollView];
    [self initScrollViewContents];
    
    _cursorLineView = [[UIView alloc]init];
    _cursorLineView.frame = CGRectMake(0, 0, 20, 3);
    _cursorLineView.backgroundColor = [UIColor hexColor:cursorViewColorString];
    [_contentScrollView addSubview:_cursorLineView];
    
    if ([_titleButtons count] > 0) {
        UIButton *firstButton = _titleButtons[0];
        _cursorLineView.center = CGPointMake(firstButton.center.x, CGRectGetMaxY(firstButton.frame)-CGRectGetHeight(_cursorLineView.frame)/2.0);
        _cursorOffsetX = CGRectGetMinX(_cursorLineView.frame);
    }
    
}

- (void)initScrollView {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    _buttonWidth = width/MIN(_titles.count, maxCount);
    
    _contentScrollView = [[UIScrollView alloc]init];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.frame = CGRectMake(0, 0, width, height);
    _contentScrollView.contentSize = CGSizeMake(_buttonWidth*_titles.count, CGRectGetHeight(_contentScrollView.frame));
    [self addSubview:_contentScrollView];
}

- (void)initScrollViewContents {
    CGFloat height = CGRectGetHeight(_contentScrollView.frame);
    
    for (int i = 0; i<_titles.count; i++) {
        NSString *title = _titles[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.frame = CGRectMake(_buttonWidth*i, 0, _buttonWidth, height);
        [_contentScrollView addSubview:button];
        button.tag = i;
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];

        [_titleButtons addObject:button];
    }
}

- (void)buttonEvent:(UIButton *)button {
    if (button.isSelected) { return; }
    
    for (int i = 0; i<_titleButtons.count; i++) {
        UIButton *button = _titleButtons[i];
        button.selected = false;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    
    button.selected = true;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];

    if ([self.delegate respondsToSelector:@selector(tabButtonSelectedIndex:)]) {
        [self.delegate tabButtonSelectedIndex:button.tag];
    }
}


#pragma mark - public method
- (void)offsetXRatio:(CGFloat)ratio {
    CGRect cursorFrame = _cursorLineView.frame;
    cursorFrame.origin.x = _cursorOffsetX+(_contentScrollView.contentSize.width * ratio);
    _cursorLineView.frame = cursorFrame;
}

- (void)refreshSelectedWithRatio:(CGFloat)ratio {
    CGFloat pageRatio = 1.0/_titles.count;
    NSInteger nextIndex = MIN((ratio / pageRatio), _titles.count-1);
    [self buttonEvent:_titleButtons[nextIndex]];
    
    //如果游标出了屏幕，需要偏移
//    CGFloat offsetX = pageRatio * _contentScrollView.contentSize.width;
//    if ()
}

- (void)addViewShadow {
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowColor = [UIColor hexColor:backgroudColorString].CGColor;
}

- (void)changeCursorLineViewColor:(UIColor *)color {
    _cursorLineView.backgroundColor = color;
}

- (void)changeBackgroundColor:(UIColor *)color {
    self.backgroundColor = color;
}

- (void)changeTitleSelectedColor:(UIColor *)selectedColor normalColor:(UIColor *)normalColor {
    
}

@end
