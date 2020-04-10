//
//  UILabel+TextSize.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/27.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "UILabel+TextSize.h"

@implementation UILabel (TextSize)

- (CGSize)boundingRectWithSize:(CGSize)size
{
    NSDictionary *attribute = @{NSFontAttributeName: self.font};
    
    CGSize retSize = [self.text boundingRectWithSize:size
                                             options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    
    return retSize;
}


@end
