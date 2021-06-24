//
//  WhiteBalanceController.m
//  TreasureChest
//
//  Created by imvt on 2021/6/24.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "WhiteBalanceController.h"
#import "CapturePipeline.h"
#import "CameraPreview.h"

@interface WhiteBalanceController () <CapturePipelineDelegate>

@property(nonatomic, strong)CapturePipeline *capturePipeline;
@property(nonatomic, strong)CameraPreview *preview;
@property(nonatomic, strong)UILabel *gainView;

@end

@implementation WhiteBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubview];
    
    self.capturePipeline = [[CapturePipeline alloc]init];
    self.capturePipeline.delegate = self;
    self.capturePipeline.sessionPreset = AVCaptureSessionPreset1280x720;
    [self.capturePipeline prepareRunning];
    [self.capturePipeline startRunning];
    self.preview.previewLayer.session = self.capturePipeline.captureSession;
}

#pragma mark - < delegate >
- (void)capturePipelineDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureWhiteBalanceGains whiteBalanceGain = self.capturePipeline.videoDevice.deviceWhiteBalanceGains;
        NSString *result = [NSString stringWithFormat:@"balance gains:\n red: %f\n green: %f\n blue: %f",whiteBalanceGain.redGain,whiteBalanceGain.greenGain,whiteBalanceGain.blueGain];
        self.gainView.text = result;
    });
}

#pragma mark - < init >
- (void)setupSubview {
    self.preview = [[CameraPreview alloc]init];
    self.preview.frame = self.view.frame;
    [self.view addSubview:self.preview];
    
    self.gainView = [[UILabel alloc]init];
    self.gainView.layer.borderWidth = 1;
    self.gainView.textColor = [UIColor redColor];
    self.gainView.numberOfLines = 5;
    self.gainView.font = [UIFont systemFontOfSize:19];
    [self.view addSubview:self.gainView];
    self.gainView.frame = CGRectMake(20, 69, 300, 140);
}

@end
