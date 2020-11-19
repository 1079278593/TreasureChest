//
//  LottieAnimationsCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/23.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "LottieAnimationsCtl.h"
#import "LottieAnimationsCell.h"

@interface LottieAnimationsCtl () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray *datas;

@end

@implementation LottieAnimationsCtl

- (void)viewDidLoad {
    [super viewDidLoad];

    self.datas = [NSMutableArray arrayWithArray:[self getDatas]];
    self.collectionView.frame = CGRectMake(10, 64, KScreenWidth-19, KScreenHeight-64);
    [self.view addSubview:self.collectionView];
}

- (NSArray *)getDatas {
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"lotties" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSArray *lotties = [bundle pathsForResourcesOfType:@"" inDirectory:@""];
    return lotties;
}


#pragma mark - < delegate >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;//太卡，展示6个
    return self.datas.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat width = (KScreenWidth - 4*10)/3.0;
//    return CGSizeMake(width, 150);
    CGFloat width = (KScreenWidth - 4*10)/1.0;
//    return CGSizeMake(width, width/(1080/600.0));
    return CGSizeMake(width, 300);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"id_%ld",(long)indexPath.row];
    [self.collectionView registerClass:[LottieAnimationsCell class] forCellWithReuseIdentifier:identifier];
    LottieAnimationsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell refreshCell:self.datas[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - < init >

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.alwaysBounceVertical = true;//数据少时也能滚动
//        [_collectionView registerClass:[LottieAnimationsCell class] forCellWithReuseIdentifier:NSStringFromClass([LottieAnimationsCell class])];
    }
    return _collectionView;
}

@end
