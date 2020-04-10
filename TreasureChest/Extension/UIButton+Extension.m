//
//  UIButton+Extension.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)



- (void)imageLayout:(ButtonImageLayout)style centerPadding:(CGFloat)padding {

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIEdgeInsets newImageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets newTitleEdgeInsets = UIEdgeInsetsZero;
    
    CGFloat titleWidth = self.titleLabel.frame.size.width;
    CGFloat titleHeight = self.titleLabel.frame.size.height;
    
    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    switch (style) {
        case ImageLayoutLeft:
        {
            newImageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, padding);
            newTitleEdgeInsets = UIEdgeInsetsMake(0, padding, 0, 0);
        }
            break;
        case ImageLayoutRight:
        {
            newImageEdgeInsets = UIEdgeInsetsMake(0, titleWidth+padding, 0, -titleWidth);
            newTitleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth + padding);
        }
            break;
        case ImageLayoutTop:
        {
            CGFloat imageMoveTopDistance = titleHeight + padding;
            CGFloat titleMoveBottomDistance = imageHeight + padding;
            CGFloat imageMoveRightDistance = titleWidth;
            CGFloat titleMoveLeftDistance = imageWidth;
            
            newImageEdgeInsets = UIEdgeInsetsMake(0, imageMoveRightDistance, imageMoveTopDistance, 0);
            newTitleEdgeInsets = UIEdgeInsetsMake(titleMoveBottomDistance, 0, 0, titleMoveLeftDistance);
        }
            break;
        case ImageLayoutBottom:
        {
            CGFloat imageMoveTopDistance = titleHeight + padding;
            CGFloat titleMoveBottomDistance = imageHeight + padding;
            CGFloat imageMoveRightDistance = titleWidth;
            CGFloat titleMoveLeftDistance = imageWidth;
            
            newImageEdgeInsets = UIEdgeInsetsMake(imageMoveTopDistance, imageMoveRightDistance, 0, 0);
            newTitleEdgeInsets = UIEdgeInsetsMake(0, 0, titleMoveBottomDistance, titleMoveLeftDistance);
        }
            break;
        default:
            break;
    }
    
    self.imageEdgeInsets = newImageEdgeInsets;
    self.titleEdgeInsets = newTitleEdgeInsets;
}

@end
