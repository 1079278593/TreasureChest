//
//  FacePointPathLayer.h
//  TreasureChest
//
//  Created by jf on 2020/10/14.
//  Copyright © 2020 xiao ming. All rights reserved.
//  人脸关键点组成的线段

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN

@interface FacePointPathLayer : CALayer

- (instancetype)initWithDeviceResolution:(CGSize)captureDeviceResolution;


/**
 FacePointPathLayer 的 size 设置为：capture Device Resolution
 
 AVCaptureVideoPreviewLayer的size是设备宽高，但是假如设置的分辨率为640*480，设备size显然就不对，这时就会通过改变宽度来适配比例，比如375*667的设备，就会变成500*667，显示中间部分。左右两边有看不见的视频内容。
 
 videoPreviewRect  即(-a ,0 ,375+2*a ,667)。将这个layer的size同步成videoPreviewRect。
 
 videoPreviewRect 是由 AVCaptureVideoPreviewLayer的方法：rectForMetadataOutputRectOfInterest转换而来。已经将设备的旋转考虑在内
 
 faceObservations的数量：人脸数量
 */
- (void)refreshWithLandmarkResults:(NSArray <VNFaceObservation *> *)faceObservations videoPreviewRect:(CGRect)videoPreviewRect;

@end

NS_ASSUME_NONNULL_END
