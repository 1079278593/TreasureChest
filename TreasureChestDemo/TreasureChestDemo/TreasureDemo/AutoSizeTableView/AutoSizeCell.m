//
//  AutoSizeCell.m
//  TreasureChest
//
//  Created by ming on 2020/11/1.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "AutoSizeCell.h"
#import "AutoSizeView.h"

#import "UIView+SDAutoLayout.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

@interface AutoSizeCell ()

@property(nonatomic, strong)UIView *lineView;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UIImageView *imgView;
@property(nonatomic, strong)UILabel *praiseLabel;
@property(nonatomic, strong)AutoSizeView *autoSizeView;

@end

@implementation AutoSizeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - < init view >
- (void)setupSubviews {
    _lineView = [[UIView alloc]init];
    _lineView.backgroundColor = [UIColor grayColor];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.backgroundColor = [UIColor redColor];
    _nameLabel.numberOfLines = 0;
    
    _imgView = [[UIImageView alloc]init];
    _imgView.backgroundColor = [UIColor orangeColor];
    
    _praiseLabel = [[UILabel alloc]init];
    _praiseLabel.backgroundColor = [UIColor yellowColor];
    
    _autoSizeView = [[AutoSizeView alloc]init];
    _autoSizeView.backgroundColor = [UIColor lightGrayColor];
    
    [self.contentView sd_addSubviews:@[_lineView,_nameLabel,_imgView,_praiseLabel,_autoSizeView]];
    
    _lineView.sd_layout
    .topSpaceToView(self.contentView, 10)
    .leftSpaceToView(self.contentView, 10)
    .widthIs(300)
    .heightIs((10));
    
    _nameLabel.sd_layout
    .topSpaceToView(_lineView, 10)
    .leftEqualToView(_lineView)
    .rightSpaceToView(self.contentView, 10)
    .autoHeightRatio(0);
    
    _imgView.sd_layout
    .topSpaceToView(_nameLabel, 10)
    .leftEqualToView(_nameLabel)
    .widthIs(100)
    .heightIs(100);
    
    _autoSizeView.sd_layout
    .topSpaceToView(_imgView, 10)
    .leftSpaceToView(_imgView, 30)
    .rightSpaceToView(self.contentView, 10);
    
}

- (void)setModel:(AutoSizeModel *)model
{
    _model = model;
    
    _imgView.image = [UIImage imageNamed:@"face2"];
    _nameLabel.text = model.content;
//    _view0.image = [UIImage imageNamed:model.iconName];
//
//    _view1.text = model.name;
//
//    _view2.text = model.content;
    
    CGFloat bottomMargin = 10;
    
    _imgView.sd_layout.autoHeightRatio(6/2.0);
    // 在实际的开发中，网络图片的宽高应由图片服务器返回然后计算宽高比。
    

    //***********************高度自适应cell设置步骤************************
    
    [self setupAutoHeightWithBottomView:_autoSizeView bottomMargin:bottomMargin];
}
@end
