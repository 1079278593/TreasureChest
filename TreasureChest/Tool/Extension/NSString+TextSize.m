//
//  NSString+TextSize.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/27.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "NSString+TextSize.h"

@implementation NSString (TextSize)

- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth font:(UIFont *)font {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    CGSize size = [self sizeWithMaxWidth:maxWidth addributes:attributes];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
    CGSize size = [self sizeWithMaxWidth:maxWidth addributes:attributes];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize fontName:(NSString *)fontName
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];
    CGSize size = [self sizeWithMaxWidth:maxWidth addributes:attributes];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

//-----------------
- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth addributes:(NSDictionary *)attributes
{
    CGSize maxSize = CGSizeMake(maxWidth, MAXFLOAT);
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

@end
