//
//  XMSelectedButton.h
//  cigarette
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 by.huang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SelectedButtonAlignment){
    ImageAlignmentLeft,
    ImageAlignmentRight
};

NS_ASSUME_NONNULL_BEGIN

@interface XMSelectedButton : UIButton

@property(assign, nonatomic)SelectedButtonAlignment alignment;
@property(strong, nonatomic)UILabel *selectedLabel;
@property(strong, nonatomic)UIImageView *iconImageView;

- (void)showWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
