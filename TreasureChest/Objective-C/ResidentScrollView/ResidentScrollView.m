//
//  ResidentScrollView.m
//  TreasureChest
//
//  Created by ming on 2019/12/7.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "ResidentScrollView.h"
#import <Masonry/Masonry.h>
//#import <Rea>
#import "ReactiveObjC.h"
@interface ResidentScrollView()<UIScrollViewDelegate>

@property(strong, nonatomic)UIView *headerView;
@property(strong, nonatomic)UITableView *tableView;

@end

@implementation ResidentScrollView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = true;
//        self.layer.masksToBounds = false;
        [self initView];
    }
    return self;
}

- (void)showResident:(UITableView *)contentView headerView:(UIView *)headerView residentHeight:(CGFloat)height {
    self.headerView = headerView;
    self.tableView = contentView;
    
    [self addSubview:self.headerView];
    headerView.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.tableView];
    contentView.backgroundColor = [UIColor blueColor];
    
    CGRect newFrame = contentView.frame;
    newFrame.origin.y = headerView.frame.size.height;
    newFrame.size.height = (self.frame.size.height - newFrame.origin.y) + height;
    contentView.frame = newFrame;

    CGFloat pointY = CGRectGetMaxY(newFrame);
    self.contentSize = CGSizeMake(self.frame.size.width, pointY);
}

- (void)initView {
//    _headerView = [[UIView alloc]init];
//    _headerView.frame = CGRectZero;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f",scrollView.contentOffset.y);
}
@end
