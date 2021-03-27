//
//  WaveButton.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/2.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WaveAnimationType){
    WaveAnimationTypeLiner = 1,    //线性
    WaveAnimationTypeEaseIn,       //
    WaveAnimationTypeEaseOut,      //
    WaveAnimationTypeEaseInOut,    //
};

NS_ASSUME_NONNULL_BEGIN

@interface WaveButton : UIButton

- (void)refreshWithImgPath:(NSString *)imgPath;

@end

NS_ASSUME_NONNULL_END
