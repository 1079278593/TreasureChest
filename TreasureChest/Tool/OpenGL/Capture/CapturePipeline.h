//
//  CapturePipeline.h
//  Poppy_Dev01
//
//  Created by jf on 2020/10/20.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CapturePipeline;

@protocol CapturePipelineDelegate <NSObject>

@required
- (void)capturePipelineDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface CapturePipeline : NSObject

@property(nonatomic, weak)id delegate;
@property(nonatomic, strong)AVCaptureSession *captureSession;
@property(nonatomic, strong)AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong)AVCaptureDevice *videoDevice;
@property(nonatomic, strong)AVCaptureConnection *videoConnection;
@property(nonatomic, assign)AVCaptureSessionPreset sessionPreset;

- (void)prepareRunning;
- (void)startRunning;
- (void)pauseRunning;
- (void)stopRunning;

@end
