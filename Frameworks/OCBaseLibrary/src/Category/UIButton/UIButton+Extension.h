//
//  UIButton+Extension.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
前提：系统默认图片左、label右的布局。
核心思路是：根据‘前提’去取消偏移，达到自己希望的布局。
注意：这个方法调用的时机，必须在title、image、frame设置之后。(思考：让其可以不用考虑调用时机)

注意：控制imageView和titleLabel的间距时，edgeInsets是否起作用，会受到contentHorizontalAlignment影响。
1. 如果是UIControlContentHorizontalAlignmentRight，imageEdgeInsets和titleEdgeInsets只有right分量起作用。
2.如果是UIControlContentHorizontalAlignmentLeft，imageEdgeInsets和titleEdgeInsets只有left分量起作用。
3.如果是默认，即center，imageEdgeInsets和titleEdgeInsets只有left、right分量起一半作用。

建议：所以如果从头写一个个的尝试，建议每次写一个方向，比如UIControlContentHorizontalAlignmentRight，
       edgeInsets设置根据两个元素的布局，取二者的中间的方向。比如图片在上，那就设置图片的bottom，
       以及label的top。

//局限：image的尺寸过大，会有问题
*/



typedef NS_ENUM(NSInteger, ButtonImageLayout){
    ImageLayoutTop,
    ImageLayoutLeft,
    ImageLayoutBottom,
    ImageLayoutRight
};

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Extension)

///padding是title和image的间距。
- (void)imageLayout:(ButtonImageLayout)style centerPadding:(CGFloat)padding;

@end

NS_ASSUME_NONNULL_END
