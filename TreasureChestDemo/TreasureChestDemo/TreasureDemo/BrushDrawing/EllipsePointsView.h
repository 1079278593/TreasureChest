//
//  EllipsePointsView.h
//  TreasureChest
//
//  Created by jf on 2020/8/6.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EllipsePointsView : UIView

- (void)createEllipse:(CGSize)brushSize;
- (void)createRect:(CGSize)brushSize;
- (void)createBrushWithSize:(CGSize)brushSize;

@end

NS_ASSUME_NONNULL_END
