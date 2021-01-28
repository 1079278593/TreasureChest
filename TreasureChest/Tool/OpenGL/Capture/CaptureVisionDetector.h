//
//  CaptureVisionDetector.h
//  Poppy_Dev01
//
//  Created by jf on 2020/12/23.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>

@protocol CaptureVisionDetectorDelegate <NSObject>

- (void)visionDetectorResult:(VNFaceObservation *)targetFaceObservation;

@end


@interface CaptureVisionDetector : NSObject

@property(nonatomic, weak)id<CaptureVisionDetectorDelegate> delegate;

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;

- (void)prepareVisionRequest;
- (void)visionRequestFromPixelBuffer:(CVImageBufferRef)pixelBuffer;
- (void)stopDetect;

@end

