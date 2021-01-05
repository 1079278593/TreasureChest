//
//  FacePointsView.h
//  TreasureChest
//
//  Created by jf on 2020/10/14.
//  Copyright © 2020 xiao ming. All rights reserved.
//  这里没有绘制，用另外一个demo去做了。可以参考绘制的顺序：下半脸、左眉毛、右眉毛、左眼、右眼。

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN

@interface FacePointsView : UIView

//@property(nonatomic, assign)CGSize resolution;
- (void)refreshWithLandmarkResults:(NSArray <VNFaceObservation *> *)faceObservations videoPreviewRect:(CGRect)videoPreviewRect;

@end

NS_ASSUME_NONNULL_END
