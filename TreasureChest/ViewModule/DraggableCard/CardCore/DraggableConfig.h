//
//  DraggableConfig.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#ifndef DraggableConfig_h
#define DraggableConfig_h

//  -------------------------------------------------
//  MARK: 拽到方向枚举
//  -------------------------------------------------
typedef NS_OPTIONS(NSInteger, DraggableDirection) {
    DraggableDirectionDefault     = 0,
    DraggableDirectionLeft        = 1 << 0,
    DraggableDirectionRight       = 1 << 1
};

#define CCWidth  [UIScreen mainScreen].bounds.size.width
#define CCHeight [UIScreen mainScreen].bounds.size.height

static const CGFloat kBoundaryRatio = 0.05f;//设置水平偏移多少能划走，原来是：0.5，感觉不是很灵敏，调成0.05；
// static const CGFloat kSecondCardScale = 0.98f;
// static const CGFloat kTherdCardScale  = 0.96f;
static const CGFloat kFirstCardScale  = 1.08f;
static const CGFloat kSecondCardScale = 1.04f;

static const CGFloat kCardEdage = 10.0f;
static const CGFloat kContainerEdage = 30.0f;
static const CGFloat kNavigationHeight = 64.0f;
static const CGFloat kVisibleCount = 3;

#endif /* DraggableConfig_h */
