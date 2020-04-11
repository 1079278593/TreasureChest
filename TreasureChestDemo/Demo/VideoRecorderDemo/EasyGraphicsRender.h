//
//  EasyGraphicsRender.h
//  TreasureChest
//
//  Created by xiao ming on 2020/4/11.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasyGraphicsRender : UIGraphicsRenderer

+ (UIImage*)resizeImage:(UIImage*)image size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
