//
//  UILabel+Insets.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/3.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "UILabel+Insets.h"
#import <objc/runtime.h>

static char kContentInsetsKey;
static char kshowContentInsetsKey;

@implementation UILabel (Insets)

+ (void)load {
    [super load];

    // class_getInstanceMethod()
    Method fromMethod = class_getInstanceMethod([self class], @selector(drawTextInRect:));
    Method toMethod = class_getInstanceMethod([self class], @selector(tt_drawTextInRect:));

    // class_addMethod()
    if (!class_addMethod([self class], @selector(drawTextInRect:), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    objc_setAssociatedObject(self, &kContentInsetsKey, NSStringFromUIEdgeInsets(contentInsets), OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &kshowContentInsetsKey, @YES, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsFromString(objc_getAssociatedObject(self, &kContentInsetsKey));
}

- (void)tt_drawTextInRect:(CGRect)rect {
    BOOL show = objc_getAssociatedObject(self, &kshowContentInsetsKey);
    if (show) {
        rect = UIEdgeInsetsInsetRect(rect, self.contentInsets);
    }
    [self tt_drawTextInRect:rect];
}


@end
