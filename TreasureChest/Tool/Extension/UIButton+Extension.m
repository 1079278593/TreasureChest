//
//  UIButton+Extension.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)

- (void)imageAlignment:(ButtonImageLayout)style padding:(CGFloat)padding {
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize buttonSize = self.frame.size;
    
    UIEdgeInsets newImageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets newTitleEdgeInsets = UIEdgeInsetsZero;
    
    CGFloat maxHeight = imageSize.height + titleSize.height + padding;
    CGFloat imageTop = (imageSize.height - maxHeight)/2.0;
    CGFloat titleBottom = (titleSize.height - maxHeight)/2.0;
    
    switch (style) {
        case ImageLayoutTop:
        {
            CGFloat imageRight = buttonSize.width > imageSize.width ? -titleSize.width : 0;
            newImageEdgeInsets = UIEdgeInsetsMake(imageTop, 0, -imageTop, imageRight);
            newTitleEdgeInsets = UIEdgeInsetsMake(-titleBottom, -imageSize.width, titleBottom, 0);
        }
            break;
        case ImageLayoutLeft:
        {
            newImageEdgeInsets = UIEdgeInsetsMake(0, -padding/2.0, 0, padding/2.0);
            newTitleEdgeInsets = UIEdgeInsetsMake(0, padding/2.0, 0, -padding/2.0);
        }
            break;
        case ImageLayoutBottom:
        {
            CGFloat imageRight = buttonSize.width > imageSize.width ? -titleSize.width : 0;
            newImageEdgeInsets = UIEdgeInsetsMake(-imageTop, 0, imageTop, imageRight);
            newTitleEdgeInsets = UIEdgeInsetsMake(titleBottom, -imageSize.width, -titleBottom, 0);
        }
            break;
        case ImageLayoutRight:
        {
            CGFloat imageLeft = titleSize.width + padding/2.0;
            CGFloat titleLeft = -(imageSize.width + padding/2.0);
            newImageEdgeInsets = UIEdgeInsetsMake(0, imageLeft, 0, -imageLeft);
            newTitleEdgeInsets = UIEdgeInsetsMake(0, titleLeft, 0, -titleLeft);
        }
            break;
        default:
            break;
    }
    
    self.imageEdgeInsets = newImageEdgeInsets;
    self.titleEdgeInsets = newTitleEdgeInsets;
}

@end
