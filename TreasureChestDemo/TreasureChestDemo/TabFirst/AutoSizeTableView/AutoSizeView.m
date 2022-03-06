//
//  AutoSizeView.m
//  TreasureChest
//
//  Created by ming on 2020/11/1.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "AutoSizeView.h"
#import "UIView+SDAutoLayout.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

@interface AutoSizeView ()

@property(nonatomic, strong)UIView *view1;
@property(nonatomic, strong)UIView *view2;

@end

@implementation AutoSizeView

- (instancetype)init {
    if(self == [super init]){
        [self setupSubviews];
    }
    return self;
}

#pragma mark - < init view >
- (void)setupSubviews {
    _view1 = [[UIView alloc]init];
    _view1.layer.cornerRadius = 5;
    _view1.backgroundColor = [UIColor greenColor];
    
    _view2 = [[UIView alloc]init];
    _view2.backgroundColor = [UIColor purpleColor];
    
    [self sd_addSubviews:@[_view1,_view2]];
    
    _view1.sd_layout
    .leftSpaceToView(self, 10)
    .topSpaceToView(self, 10)
    .widthIs(100)
    .heightIs(30);
    
    _view2.sd_layout
    .leftSpaceToView(_view1, 20)
    .topSpaceToView(_view1, 10)
    .widthIs(30)
    .heightIs(60);
    
    [self setupAutoHeightWithBottomView:_view2 bottomMargin:10];
}

@end
