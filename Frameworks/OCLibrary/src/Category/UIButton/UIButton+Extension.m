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
        {//这里待优化，width一定要够宽，不然显示不正常
            CGFloat imageMoveTopDistance = titleHeight + padding;
            CGFloat titleMoveBottomDistance = imageHeight + padding;
            CGFloat imageMoveRightDistance = titleWidth*0.5;
            CGFloat titleMoveLeftDistance = imageWidth;// + (titleWidth > imageWidth ? (titleWidth - imageWidth) : 0);
            //图片左边收缩，右边扩展
            newImageEdgeInsets = UIEdgeInsetsMake(0, imageMoveRightDistance, imageMoveTopDistance, -imageMoveRightDistance);
            newTitleEdgeInsets = UIEdgeInsetsMake(titleMoveBottomDistance, -10, 0, titleMoveLeftDistance-10);
        }
            break;
        case ImageLayoutBottom:
        {
            CGFloat imageMoveTopDistance = titleHeight + padding;
            CGFloat titleMoveBottomDistance = imageHeight + padding;
            CGFloat imageMoveRightDistance = titleWidth*0.5;
            CGFloat titleMoveLeftDistance = imageWidth;
            
            newImageEdgeInsets = UIEdgeInsetsMake(imageMoveTopDistance, imageMoveRightDistance, 0, -imageMoveRightDistance);
            newTitleEdgeInsets = UIEdgeInsetsMake(0, -20, titleMoveBottomDistance, titleMoveLeftDistance-20);
        }
            break;
        default:
            break;
    }
    
    self.imageEdgeInsets = newImageEdgeInsets;
    self.titleEdgeInsets = newTitleEdgeInsets;
}

@end
