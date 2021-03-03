//
//  ViewController.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "DraggableCardController.h"
#import "DraggableContainer.h"
#import "CustomCardView.h"

#import <Masonry.h>

@interface DraggableCardController ()
<
DraggableContainerDataSource,
DraggableContainerDelegate
>

@property (nonatomic, strong) DraggableContainer *container;
@property (nonatomic, strong) NSMutableArray *dataSources;

@property (weak, nonatomic) UIButton *disLikeButton;
@property (weak, nonatomic) UIButton *likeButton;
@property (weak, nonatomic) UIButton *detailBtn;

@end

@implementation DraggableCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithButton];
    [self loadData];
    [self loadUI];
}

#pragma mark - < event >
- (void)reloadDataEvent:(id)sender {
    if (self.container) {
        [self.container reloadData];
    }
}

- (void)dislikeEvent:(id)sender {
    [self.container removeFormDirection:DraggableDirectionLeft];
}

- (void)likeEvent:(id)sender {
    [self.container removeFormDirection:DraggableDirectionRight];
}

///rac，接口数据
- (void)loadData {
    _dataSources = [NSMutableArray array];
    
    for (int i = 0; i < 9; i++) {
        NSDictionary *dict = @{@"image" : [NSString stringWithFormat:@"image_%d.jpg",i + 1],
                               @"title" : [NSString stringWithFormat:@"Page %d",i + 1]};
        [_dataSources addObject:dict];
    }
}

#pragma mark - DraggableContainer DataSource
- (DraggableCardView *)draggableContainer:(DraggableContainer *)draggableContainer viewForIndex:(NSInteger)index {
    CustomCardView *cardView = [[CustomCardView alloc] initWithFrame:draggableContainer.bounds];
    [cardView refreshWithData:[_dataSources objectAtIndex:index]];
    return cardView;
}

- (NSInteger)numberOfIndexs {
    return _dataSources.count;
}

#pragma mark - DraggableContainer Delegate
- (void)draggableContainer:(DraggableContainer *)draggableContainer draggableDirection:(DraggableDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio {
    
    CGFloat scale = 1 + ((kBoundaryRatio > fabs(widthRatio) ? fabs(widthRatio) : kBoundaryRatio)) / 4;
    if (draggableDirection == DraggableDirectionLeft) {
        self.disLikeButton.transform = CGAffineTransformMakeScale(scale, scale);
    }
    if (draggableDirection == DraggableDirectionRight) {
        self.likeButton.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)draggableContainer:(DraggableContainer *)draggableContainer cardView:(DraggableCardView *)cardView didSelectIndex:(NSInteger)didSelectIndex {
    NSLog(@"点击了Tag为%ld的Card", (long)didSelectIndex);
}

- (void)draggableContainer:(DraggableContainer *)draggableContainer finishedDraggableLastCard:(BOOL)finishedDraggableLastCard {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.40 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [draggableContainer reloadData];
    });
}

#pragma mark - < init >
- (void)loadUI {
    self.container = [[DraggableContainer alloc] initWithFrame:CGRectMake(0, 84, CCWidth, CCHeight - 84 - 30)];
    self.container.delegate = self;
    self.container.dataSource = self;
    [self.view addSubview:self.container];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.container reloadData];
}

- (void)initWithButton
{
    // 防止block中的循环引用
    __weak typeof (self) weakSelf = self;
    
    UIButton *reloadDataEvent = [[UIButton alloc] init];
    self.detailBtn = reloadDataEvent;
    [self.view addSubview:reloadDataEvent];
    [reloadDataEvent setBackgroundImage:[UIImage imageNamed:@"userInfo"] forState:UIControlStateNormal];
    [reloadDataEvent addTarget:self action:@selector(reloadDataEvent:) forControlEvents:UIControlEventTouchUpInside];
    [reloadDataEvent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerX.equalTo(weakSelf.view);
        make.bottom.width.offset(-100);
    
    }];
    
    UIButton *dislikeEvent = [[UIButton alloc] init];
    self.disLikeButton = dislikeEvent;
    [dislikeEvent addTarget:self action:@selector(dislikeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dislikeEvent];
    [dislikeEvent setBackgroundImage:[UIImage imageNamed:@"nope"] forState:UIControlStateNormal];
    [dislikeEvent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.centerY.equalTo(reloadDataEvent);
        make.right.equalTo(reloadDataEvent.mas_left).with.offset(-30);
        
    }];
    
    UIButton *likeEvent = [[UIButton alloc] init];
    self.likeButton = likeEvent;
    [likeEvent addTarget:self action:@selector(likeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:likeEvent];
    [likeEvent setBackgroundImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
    [likeEvent mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.centerY.equalTo(reloadDataEvent);
        make.left.equalTo(reloadDataEvent.mas_right).with.offset(30);
    }];
}

@end
