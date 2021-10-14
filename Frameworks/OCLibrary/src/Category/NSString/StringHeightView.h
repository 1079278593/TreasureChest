//
//  StringHeightView.h
//  Poppy_Dev01
//
//  Created by jf on 2020/8/28.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StringHeightView : UIView

+ (instancetype)shareInstance;
- (CGFloat)stringHeight:(NSString *)string fontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth;
- (CGFloat)stringHeightWithLine:(int)lineNum fontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
