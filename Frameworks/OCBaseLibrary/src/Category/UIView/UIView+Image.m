//
//  UIView+Image.m
//  Poppy_Dev01
//
//  Created by ming on 2021/3/12.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "UIView+Image.h"

@implementation UIView (Image)

- (void)setImage:(UIImage *)image {
    self.layer.contents = (id)image.CGImage;
    self.layer.contentsGravity = kCAGravityResizeAspect;
    self.layer.contentsScale = image.scale;
}

@end
