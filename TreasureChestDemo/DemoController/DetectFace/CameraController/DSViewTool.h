//
//  DSViewTool.h
//  DSVisionTool
//
//  Created by dasen on 2017/7/6.
//  Copyright © 2017年 Dasen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

@interface DSViewTool : NSObject

//observation这个参数(只用了observation.boundingBox)，可以简化，或者不用传入pointArray，直接从observation.landmarks获取
+ (UIImage *)drawImage:(UIImage *)source observation:(VNFaceObservation *)observation pointArray:(NSArray *)pointArray;

+ (UIView *)getRectViewWithFrame:(CGRect)frame;
@end
