//
//  FormsView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/5.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "FormsView.h"
#import <Masonry/Masonry.h>

#define KSpacingWidth 15.0f
#define KLabelHeight 20.0f

@interface FormsView()

@property(strong, nonatomic)NSArray <NSString *> *leftTitles;
@property(strong, nonatomic)NSArray <NSString *> *rightTitles;
@property(strong, nonatomic)NSArray <NSString *> *leftItems;
@property(strong, nonatomic)NSArray <NSString *> *rightItems;

@property(strong, nonatomic)NSMutableArray <UILabel *> *leftTitleLabels;
@property(strong, nonatomic)NSMutableArray <UILabel *> *rightTitleLabels;
@property(strong, nonatomic)NSMutableArray <UILabel *> *leftItemLabels;
@property(strong, nonatomic)NSMutableArray <UILabel *> *rightItemLabels;

@end

@implementation FormsView

- (instancetype)initWithLeftTitles:(NSArray *)leftTitles leftItems:(NSArray *)leftItems {
    if(self == [super init]){
        _leftTitles = leftTitles;
        _leftItems = leftItems;
        [self initView];
    }
    return self;
}

- (void)initView {
    
    [self initTitleLabels];
    
    UIView *breakLine = [[UIView alloc]init];
    breakLine.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:breakLine];
    
//    [self initItemLabels];
}

- (void)initTitleLabels {
    if (_leftTitles.count == 0) {
        return;
    }
    
    UIView *cursorView = [[UIView alloc]init];
    [self addSubview:cursorView];
    cursorView.frame = CGRectZero;
    
    for (int i = 0; i<_leftTitles.count; i++) {
        NSString *title = _leftTitles[i];
        
        UIView *containerView = [[UIView alloc]init];
        [self addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(cursorView.mas_bottom);
        }];
        containerView.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.1+0.1*i];
        
        UILabel *leftLabel = [self getLabel];// [[UILabel alloc]init];
        leftLabel.textAlignment = NSTextAlignmentLeft;
        leftLabel.text = title;
        [self addSubview:leftLabel];
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(containerView).offset(KSpacingWidth);
            make.top.equalTo(containerView).offset(KSpacingWidth);
            make.width.equalTo(@150);
            make.height.equalTo(@KLabelHeight);
        }];
        
        UILabel *rightLabel = [self getLabel];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.text = @"";
        [self addSubview:rightLabel];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftLabel.mas_right);
            make.top.equalTo(leftLabel);
            make.right.equalTo(containerView).offset(-KSpacingWidth);
            make.bottom.equalTo(leftLabel);
        }];
        if (i == 1) {
            leftLabel.text = @"代发费第三方士大夫士大夫士大夫士大夫三大法师法士大夫撒发斯蒂芬斯蒂芬打法胜多负少的";
            [leftLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@44);
            }];
        }
        
        [containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(rightLabel);
        }];
        
        cursorView = containerView;
    }
}

- (void)initItemLabels {
    for (NSString *item in _leftItems) {
        
    }
}

//更新titlesLabel
- (void)updateTitles:(NSArray *)leftTitles rightTitles:(NSArray *)rightTitles {
    [self updateLeftTitles:leftTitles];
    [self updateRightTitles:rightTitles];
}

- (void)updateLeftTitles:(NSArray *)leftTitles {
    
}

- (void)updateRightTitles:(NSArray *)rightTitles {
    
}

//更新itemsLabel
- (void)updateItems:(NSArray *)leftItems rightItems:(NSArray *)rightItems {
    [self updateLeftItems:leftItems];
    [self updateRightItems:rightItems];
}

- (void)updateLeftItems:(NSArray *)leftItems {
    
}

- (void)updateRightItems:(NSArray *)rightItems {
    
}

#pragma mark - private method
- (UILabel *)getLabel {
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    return label;
}

@end
