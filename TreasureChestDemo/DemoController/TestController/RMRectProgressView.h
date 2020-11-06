//
//  RMRectProgressView.h
//  RemoApp
//
//  Created by RemoMac on 2018/10/8.
//  Copyright © 2018 Remo. All rights reserved.
//  进度条

#import <UIKit/UIKit.h>
#define KCycleLineWidth 2
#define KCycelLineColor [UIColor hexColor:@"#CBCBCB"]
#define KCycelLineCornerRadius 5

NS_ASSUME_NONNULL_BEGIN

@interface RMRectProgressView : UIView

@property(nonatomic,assign)CGFloat progress;

@end

NS_ASSUME_NONNULL_END
