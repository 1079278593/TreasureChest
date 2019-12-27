//
//  FormsView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/5.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "FormsView.h"
#import "Masonry.h"

#define KSpacingWidth 15.0f
#define KLabelHeight 20.0f

@interface FormsView()

@property(strong, nonatomic)NSArray <NSString *> *leftTitles;
@property(strong, nonatomic)NSArray <NSString *> *rightTitles;

@property(strong, nonatomic)NSMutableArray <UILabel *> *leftTitleLabels;
@property(strong, nonatomic)NSMutableArray <UILabel *> *rightTitleLabels;

@property(assign, nonatomic)CGFloat totalHeight;

@end

@implementation FormsView

- (instancetype)initWithFrame:(CGRect)frame leftTitles:(NSArray *)leftTitles {
    if(self == [super initWithFrame:frame]){
        _leftTitles = leftTitles;
        _leftTitleLabels = [NSMutableArray arrayWithCapacity:0];
        _rightTitleLabels = [NSMutableArray arrayWithCapacity:0];
        [self initView];
    }
    return self;
}

#pragma mark - < public >
- (void)updateLeftTitles:(NSArray *)leftTitles rightTitles:(NSArray *)rightTitles {
    [self updateLeftTitles:leftTitles];
    [self updateRightTitles:rightTitles];
}

- (void)updateLeftTitles:(NSArray *)leftTitles {
    _leftTitles = leftTitles;
    [self refreshLabels:self.leftTitleLabels titles:leftTitles];
    [self refreshHeight];
}

- (void)updateRightTitles:(NSArray *)rightTitles {
    _rightTitles = rightTitles;
    [self refreshLabels:self.rightTitleLabels titles:rightTitles];
    [self refreshHeight];
}

- (CGFloat)getFormsHeight {
    return self.totalHeight;
}

#pragma mark - < 刷新 >
- (void)refreshLabels:(NSArray *)labels titles:(NSArray *)titles {
    for (int i = 0; i<titles.count; i++) {
        UILabel *label = labels[i];
        label.text = titles[i];
    }
}

- (void)refreshHeight {

    self.totalHeight = 0;
    
    CGFloat viewWidth = self.width;
    CGFloat leftWidth = 120;
    CGFloat rightWidth = viewWidth - leftWidth - 15*2;
      
    UIView *cursorView = [[UIView alloc]init];
    [self addSubview:cursorView];
    cursorView.frame = CGRectZero;
      
    for (int i = 0; i<_leftTitles.count; i++) {
        UILabel *leftLabel = self.leftTitleLabels[i];
        CGFloat height = [leftLabel.text sizeWithMaxWidth:leftWidth font:leftLabel.font].height;
        height = MAX(height, 20);
        leftLabel.frame = CGRectMake(15, cursorView.bottom+15, leftWidth, height);
    
        UILabel *rightLabel = self.rightTitleLabels[i];
        height = [rightLabel.text sizeWithMaxWidth:rightWidth font:rightLabel.font].height;
        height = MAX(height, 20);
        rightLabel.frame = CGRectMake(leftLabel.right, leftLabel.y, rightWidth, height);
        
        cursorView = CGRectGetMaxY(leftLabel.frame) > CGRectGetMaxY(rightLabel.frame) ? leftLabel : rightLabel;
        
        self.totalHeight = cursorView.bottom;
    }
}

#pragma mark - < init view >
- (void)initView {
    [self initTitleLabels];
    [self updateLeftTitles:_leftTitles];
}

- (void)initTitleLabels {
    if (_leftTitles.count == 0) {
        return;
    }
    for (int i = 0; i<_leftTitles.count; i++) {
        UILabel *leftLabel = [self getLabel];
        UILabel *rightLabel = [self getLabel];
        rightLabel.textAlignment = NSTextAlignmentRight;
        
        [self.leftTitleLabels addObject:leftLabel];
        [self.rightTitleLabels addObject:rightLabel];
        
        rightLabel.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.1+0.1*i];
    }
}

- (UILabel *)getLabel {
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:14];
    [self addSubview:label];
    return label;
}



@end
