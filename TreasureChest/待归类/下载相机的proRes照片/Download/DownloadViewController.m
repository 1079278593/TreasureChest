//
//  DownloadViewController.m
//  AwesomeCamera
//
//  Created by imvt on 2023/7/17.
//  Copyright © 2023 ImagineVision. All rights reserved.
//

#import "DownloadViewController.h"
#import "MJRefresh.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "CheckAuthorization.h"
#import "EasyPhotoLibrary.h"

#import "DownloadViewModel.h"
#import "AlbumsItemCell.h"

@interface DownloadViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,AlbumsItemCellDelegate>

@property(nonatomic, strong)DownloadViewModel *viewModel;
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)UIButton *trashButton;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self bindRACModel];
    [self setupSubViews];
    [self headerRequest];
    
    [self requestAuthrize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.keepDownloading = NO;
    [self.viewModel downloadResume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    if (!self.keepDownloading) {
//        [self.downloadMgr pause];
//    }
//    [self.bitmapLoader cancelAll];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bindRACModel {
    self.viewModel = [[DownloadViewModel alloc]init];
    
    @weakify(self);
    [[RACObserve(self.viewModel, datas) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
    }];
    
    [[RACObserve(self.viewModel, reloadEvent) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.collectionView reloadData];
    }];
    
    [[RACObserve(self.viewModel, reloadIndex) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        int index = [x intValue];
        if (index >= self.viewModel.datas.count) {
            NSLog(@"");
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        AlbumsItemCell *cell = (AlbumsItemCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell refreshCellWithModel:self.viewModel.datas[index]];
    }];
}

#pragma mark - < event >
- (void)didBecomeActive {
//    self.keepDownloading = NO;
    [self.viewModel downloadResume];
    [self.viewModel prepareDatas];
}

- (void)willResignActive {
    [self.viewModel downloadPause];
}

- (void)trashButtonEvent:(UIButton *)button {
    button.selected = !button.selected;
    [self.collectionView reloadData];
    for (int i = 0; i<self.viewModel.datas.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        AlbumsItemCell *cell = (AlbumsItemCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell hideEditButton:!self.trashButton.selected];
    }
}

- (void)requestAuthEvent:(UIButton *)button {
//    [CheckAuthorization requestAllAuthorization];
}

#pragma mark - < request >
-(void)headerRequest{
    [self.viewModel prepareDatas];
}

#pragma mark < delegate >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.datas.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.width;
    int count = IsIpad ? 4 : 3;
    CGFloat edgeSpacing = 20;       //!< 边缘
    CGFloat interitemSpacing = 20;  //!< item间距，不需要时改成0，因为有默认值
    CGFloat lineSpacing = 20;        //!< 行间距
    CGFloat itemWidth = (int)(width - interitemSpacing * (count - 1) - edgeSpacing * 2)/count;
    CGFloat itemHeight = itemWidth/(1/1.0);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = interitemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(lineSpacing, edgeSpacing, lineSpacing, edgeSpacing);//左右两侧，以及section间的间距
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumsItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AlbumsItemCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    [cell refreshCellWithModel:self.viewModel.datas[indexPath.row]];
    [cell hideEditButton:!self.trashButton.selected];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

//cell delegate
- (void)deleteSuccess:(GalleryDownloadModel *)model {
    [self.viewModel.datas removeObject:model];
    [self.collectionView reloadData];
}

#pragma mark - < private >
- (void)requestAuthrize {
    PHAssetCollection *collection = [EasyPhotoLibrary createdCollectionWithName:KAlbumName];
    if (collection == nil) {
        NSString *title = NSLocalizedString(@"Photos Authorizing", @"");
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:title];
        NSRange strRange1 = {0,[str1 length]};
        //设置下划线范围
        [str1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange1];
        //设置下划线颜色
        [str1 addAttribute:NSUnderlineColorAttributeName value:[UIColor redColor] range:strRange1];
        //将下划线绘制到按钮上
        [button setAttributedTitle:str1 forState:UIControlStateNormal];
        
        
        [button addTarget:self action:@selector(requestAuthEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(10);
            make.right.equalTo(self.view).offset(-10);
            make.top.equalTo(@(KTopBarSafeHeight+20));
            make.height.equalTo(@(40));
        }];
    }
}

#pragma mark - < init >
- (void)setupSubViews {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(KTopBarSafeHeight);
    }];
    
    _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _trashButton.frame = CGRectMake(0, 0, 60, 44);
    [_trashButton setImage:[UIImage imageNamed:@"trashFillWhite"] forState:UIControlStateNormal];
    [_trashButton setImage:[UIImage imageNamed:@"trashFill"] forState:UIControlStateSelected];
    [_trashButton addTarget:self action:@selector(trashButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *naviTrashBtnItem = [[UIBarButtonItem alloc] initWithCustomView:_trashButton];
    self.navigationController.topViewController.navigationItem.rightBarButtonItems = @[naviTrashBtnItem];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat width = KScreenWidth *0.8;
        int count = 3;
        CGFloat edgeSpacing = 10;       //!< 边缘
        CGFloat interitemSpacing = 10;  //!< item间距，不需要时改成0，因为有默认值
        CGFloat lineSpacing = 10;        //!< 行间距
        CGFloat itemWidth = (width - interitemSpacing * (count - 1) - edgeSpacing * 2)/count;
        CGFloat itemHeight = itemWidth/(1);
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = lineSpacing;
        layout.minimumInteritemSpacing = interitemSpacing;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, width, 0) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = true;//数据少时也能滚动
        [_collectionView registerClass:[AlbumsItemCell class] forCellWithReuseIdentifier:NSStringFromClass([AlbumsItemCell class])];
                
        MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRequest)];
        header.lastUpdatedTimeLabel.hidden = YES;
        _collectionView.mj_header = header;
    }
    return _collectionView;
}

@end
