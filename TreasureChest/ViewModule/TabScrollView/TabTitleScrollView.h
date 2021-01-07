//
//  TabTitleScrollView.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol  TabTitleScrollViewDelegate<NSObject>

- (void)tabButtonSelectedIndex:(NSInteger)index;

@end

@interface TabTitleScrollView : UIView

@property(weak, nonatomic)id<TabTitleScrollViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;

- (void)offsetXRatio:(CGFloat)ratio;
- (void)refreshSelectedWithRatio:(CGFloat)ratio;
- (void)addViewShadow;
- (void)changeCursorLineViewColor:(UIColor *)color;
- (void)changeBackgroundColor:(UIColor *)color;
- (void)changeTitleSelectedColor:(UIColor *)selectedColor normalColor:(UIColor *)normalColor;

@end

NS_ASSUME_NONNULL_END
