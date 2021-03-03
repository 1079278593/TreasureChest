//
//  DraggableContainer.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DraggableConfig.h"
#import "DraggableCardView.h"

@class DraggableContainer;

//  -------------------------------------------------
//  MARK: Delegate
//  -------------------------------------------------

@protocol DraggableContainerDelegate <NSObject>

- (void)draggableContainer:(DraggableContainer *)draggableContainer
        draggableDirection:(DraggableDirection)draggableDirection
                widthRatio:(CGFloat)widthRatio
               heightRatio:(CGFloat)heightRatio;

- (void)draggableContainer:(DraggableContainer *)draggableContainer
                  cardView:(DraggableCardView *)cardView
            didSelectIndex:(NSInteger)didSelectIndex;

- (void)draggableContainer:(DraggableContainer *)draggableContainer
 finishedDraggableLastCard:(BOOL)finishedDraggableLastCard;

@end

//  -------------------------------------------------
//  MARK: DataSource
//  -------------------------------------------------

@protocol DraggableContainerDataSource <NSObject>

@required
- (DraggableCardView *)draggableContainer:(DraggableContainer *)draggableContainer
                               viewForIndex:(NSInteger)index;

- (NSInteger)numberOfIndexs;

@end



//  -------------------------------------------------
//  MARK: DraggableContainer
//  -------------------------------------------------

@interface DraggableContainer : UIView

@property(nonatomic, weak)id <DraggableContainerDelegate>delegate;
@property(nonatomic, weak)id <DraggableContainerDataSource>dataSource;
@property(nonatomic, assign)DraggableDirection direction;

- (void)removeFormDirection:(DraggableDirection)direction;
- (void)reloadData;

@end
