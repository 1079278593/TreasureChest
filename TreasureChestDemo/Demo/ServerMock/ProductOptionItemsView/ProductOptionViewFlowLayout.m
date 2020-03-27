//
//  ProductOptionViewFlowLayout.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/27.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "ProductOptionViewFlowLayout.h"

@interface ProductOptionViewFlowLayout()

@property(nonatomic, strong)NSMutableArray <UICollectionViewLayoutAttributes *> *layoutAttributes;
@property(nonatomic, assign)CGSize contentSize;

@end

@implementation ProductOptionViewFlowLayout

//collectionView每次需要重新布局(初始, layout 被设置为invalidated ...)的时候会首先调用这个方法prepare()
//可以做一些初始化的操作
//在cell比较少的情况下, 我们一般都可以在这个方法里面计算好所有的cell布局,并且缓存下来, 在需要的时候直接取相应的值即可, 以提高效率
//prepare之后，会调用layoutAttributesForElements()
- (void)prepareLayout {
    [super prepareLayout];
    
    self.contentSize = CGSizeMake(KScreenWidth, 200);
    
    [self.layoutAttributes removeAllObjects];
    self.layoutAttributes = [self computeLayoutAttributes];
}

// Apple建议要重写这个方法, 因为某些情况下(delete insert...)系统可能需要调用这个方法来布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
}

//rect的size可能比collectionView的size大一些, 这样设计也许是为了提取缓冲。如果之前我们已经计算好了,直接返回就可以了
//由于系统已经帮我们做了全部的计算的事情。所以我们有时只需要重写 -layoutAttributesForElementsInRect: 这个方法即可。
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (NSMutableArray *)computeLayoutAttributes {
    
    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithCapacity:0];
    NSInteger sectionCount = [self.collectionView numberOfSections];
//    for (int i = 0, i < sectionCount, i++) {
//
//    }
//
    return [[NSMutableArray alloc]init];
}

@end

/*
private func computeLayoutAttributes() -> [UICollectionViewLayoutAttributes] {
    
    var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    let cellCount = collectionView!.numberOfItems(inSection: 0)
    contentSize.height = 0 //重置高度
    let screenWidth:CGFloat = contentSize.width
    
    for index in 0..<cellCount {
        let indexPath = IndexPath(item: index, section: 0)
        if let attributes = layoutAttributesForItem(at: indexPath) {
            let cycleIndex = indexPath.row%5
            var frame = CGRect.zero
            if cycleIndex == 0 {
                frame = CGRect(x: 0, y: contentSize.height, width: screenWidth, height: screenWidth)
                contentSize.height += (screenWidth + XMLineSpacing)
            }else {
                let col:CGFloat = 2
                let itemWidth = (screenWidth - (col-1) * XMLineSpacing)/col
                
                if cycleIndex == 1 || cycleIndex == 3 {
                    frame = CGRect(x: 0, y: contentSize.height, width: itemWidth, height: itemWidth)
                    if index+1 == cellCount {//最后一个cell
                        contentSize.height += (itemWidth + XMLineSpacing)
                    }
                }else {
                    frame = CGRect(x: itemWidth+XMItemSpacing, y: contentSize.height, width: itemWidth, height: itemWidth)
                    contentSize.height += (itemWidth + XMLineSpacing)
                }
            }
            attributes.frame = frame
            layoutAttributes.append(attributes)
        }
    }
    return layoutAttributes
}

*/
