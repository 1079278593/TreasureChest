//
//  DictionaryMainCell.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/17.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "DictionaryMainCell.h"

@interface DictionaryMainCell()

@property(nonatomic, strong)UILabel *wordLabel;
@property(nonatomic, strong)UILabel *phoneticLabel;
@property(nonatomic, strong)UILabel *translationLabel;
@property(nonatomic, strong)UIImageView *arrowView;

@end

@implementation DictionaryMainCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _wordLabel = [[UILabel alloc]init];
    _wordLabel.textAlignment = NSTextAlignmentLeft;
    _wordLabel.font = [UIFont systemFontOfSize:14];
    _wordLabel.textColor = KTextMainColor;
    [self.contentView addSubview:_wordLabel];
    _wordLabel.frame = CGRectMake(15, 10, KScreenWidth-30, 18);
    
    _phoneticLabel = [[UILabel alloc]init];
    _phoneticLabel.textAlignment = NSTextAlignmentLeft;
    _phoneticLabel.font = [UIFont systemFontOfSize:14];
    _phoneticLabel.textColor = KTextSecondColor;
    [self addSubview:_phoneticLabel];
    _phoneticLabel.frame = CGRectMake(_wordLabel.x, _wordLabel.bottom+5, 0, 15);
    
    _translationLabel = [[UILabel alloc]init];
    _translationLabel.textAlignment = NSTextAlignmentLeft;
    _translationLabel.font = [UIFont systemFontOfSize:12];
    _translationLabel.textColor = KTextSecondColor;
    [self addSubview:_translationLabel];
    _translationLabel.frame = CGRectMake(_phoneticLabel.right, _phoneticLabel.y, 0, _phoneticLabel.height);
    
    _arrowView = [[UIImageView alloc]init];
    _arrowView.image = [UIImage imageNamed:@"arrow"];
    [self.contentView addSubview:_arrowView];
    [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@20);
    }];
    
    UIView *breakLine = [[UIView alloc]init];
    breakLine.backgroundColor = KLineColor;
    [self addSubview:breakLine];
    [breakLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_wordLabel);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(_wordLabel);
        make.height.equalTo(@0.5);
    }];

}

- (void)setModel:(DictionaryMainModel *)model {
    _model = model;
    [self refreshView];
}

- (void)refreshView {
    self.wordLabel.text = self.model.word;
    self.phoneticLabel.text = [NSString stringWithFormat:@"[%@]",self.model.phonetic];
    self.translationLabel.text = self.model.translation;
    
    self.phoneticLabel.width = [self.phoneticLabel.text sizeWithMaxWidth:200 font:self.phoneticLabel.font].width;
    self.translationLabel.x = self.phoneticLabel.right + 10;
    self.translationLabel.width = KScreenWidth - self.phoneticLabel.right - 15 - 20;
}
@end
