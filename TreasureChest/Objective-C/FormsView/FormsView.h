//
//  FormsView.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/5.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FormsView : UIView

- (instancetype)initWithFrame:(CGRect)frame leftTitles:(NSArray *)leftTitles;

- (void)updateLeftTitles:(NSArray *)leftTitles rightTitles:(NSArray *)rightTitles;
- (void)updateLeftTitles:(NSArray *)leftTitles;
- (void)updateRightTitles:(NSArray *)rightTitles;
- (CGFloat)getFormsHeight;

@end

NS_ASSUME_NONNULL_END
