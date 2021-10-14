//
//  NSString+TextSize.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/27.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TextSize)

- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth font:(UIFont *)font;
- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize;
- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize fontName:(NSString *)fontName;

@end

NS_ASSUME_NONNULL_END
