//
//  ResidentScrollView.m
//  TreasureChest
//
//  Created by ming on 2019/12/7.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "ResidentScrollView.h"
//#import <Masonry/Masonry.h>
//#import <ReactiveObjC.h>
#import "Masonry.h"
#import "ReactiveObjC.h"

@interface ResidentScrollView()<UIScrollViewDelegate>

@property(strong, nonatomic)UIView *headerView;
@property(strong, nonatomic)UITableView *tableView;
@property(assign, nonatomic)CGFloat residentHeight;

@end

@implementation ResidentScrollView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = true;
        self.scrollEnabled = false;
        self.delegate = self;
//        self.layer.masksToBounds = false;
        [self initView];
    }
    return self;
}

- (void)showResident:(UITableView *)contentView headerView:(UIView *)headerView residentHeight:(CGFloat)height {
    self.headerView = headerView;
    self.tableView = contentView;
    self.residentHeight = height;
    
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
    
    [self yd_bindViewModel];
}

- (void)initView {
    
    
}

- (void)yd_bindViewModel
{
    @weakify(self);
    [RACObserve(self.tableView, contentOffset) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        CGPoint newOffset = [x CGPointValue];
        if (newOffset.x == 0 && newOffset.y == 0) {
            
        }else {
            
            if (self.contentOffset.y >= self.residentHeight) {
                
                if (newOffset.y > 0) {

//                    NSLog(@" > 0, newOffset:%f",newOffset.y);
                }else{
//                    NSLog(@"< 0, newOffset:%f",newOffset.y);
                    self.tableView.contentOffset = CGPointZero;
                    CGPoint offset = self.contentOffset;
                    self.contentOffset = CGPointMake(offset.x, offset.y + newOffset.y);

                    
                }
            }else {
                //移动整个scrollView阶段，tableview不动
                if (newOffset.y < 0 && self.contentOffset.y <= 0) {
                    
                }else {
                    self.tableView.contentOffset = CGPointZero;
                    CGPoint offset = self.contentOffset;
                    CGFloat suitableY = offset.y + newOffset.y;
                    suitableY = MIN(suitableY, self.residentHeight);
                    suitableY = MAX(0, suitableY);
                    self.contentOffset = CGPointMake(offset.x, suitableY);
                }
                
            }
            
        }
        
        
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f",scrollView.contentOffset.y);
}
@end
