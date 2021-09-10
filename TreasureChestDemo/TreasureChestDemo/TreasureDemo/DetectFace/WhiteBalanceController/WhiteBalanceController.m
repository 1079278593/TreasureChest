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
#import <Photos/Photos.h>
#import "BrightnessHistogram.h"

@interface WhiteBalanceController () <CapturePipelineDelegate, UITextFieldDelegate>

@property(nonatomic, strong)CapturePipeline *capturePipeline;
@property(nonatomic, strong)CameraPreview *preview;
@property(nonatomic, strong)UIButton *captureBtn;
@property(nonatomic, strong)UITextView *gainView;
@property(nonatomic, strong)UITextView *grayGainView;

@property(nonatomic, strong)UILabel *apertureLabel;         //!< 光圈，（光圈只读）
@property(nonatomic, strong)UISlider *ISOSlider;            //!< ISO，感光度
@property(nonatomic, strong)UISlider *shutterSlider;        //!< 快门，用来控制光线进入镜头的时间

@property(nonatomic, strong)UILabel *shutterLabel;
@property(nonatomic, strong)UILabel *ISOLabel;

@property(nonatomic, strong)CAMLineChart *lineCharView;
@property(nonatomic, strong)BrightnessHistogram *lineHistogram;
@property(nonatomic, assign)BOOL isNeedShowHistogram;

@end
/**
 
 灯app目前只有信息： r/g/b gain, cct, uv

 灯app还缺少功能， 用来对灯的亮度校准:
 1.  允许设置 iso(感光度)，shutter(快门)，aperture(光圈)（如有）
 2.  统计亮度.  (raw亮度，yuv亮度）
 
 */
@implementation WhiteBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubview];
    
    self.capturePipeline = [[CapturePipeline alloc]init];
    self.capturePipeline.delegate = self;
    self.capturePipeline.sessionPreset = AVCaptureSessionPreset640x480;
    self.capturePipeline.devicePostion = AVCaptureDevicePositionBack;
    self.capturePipeline.orientation = AVCaptureVideoOrientationPortrait;
    [self.capturePipeline prepareRunning];
    [self.capturePipeline startRunning];
    self.preview.previewLayer.session = self.capturePipeline.captureSession;
    
    self.lineHistogram = [[BrightnessHistogram alloc]init];
    self.apertureLabel.text = [NSString stringWithFormat:@"光圈(只读)：%.3f",self.capturePipeline.videoDevice.lensAperture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - < event >
- (void)backButtonEvent:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonEvent:(UIButton *)button {
//    [self.capturePipeline capturePhoto];//拍照。
    
    if (_lineCharView == nil) {
        _lineCharView = [self.lineHistogram getHistogramChartViewWithFrame:CGRectMake(0, self.preview.bottom, KScreenWidth, KScreenHeight-self.preview.bottom)];
        [self.view addSubview:_lineCharView];
    }
    self.lineCharView.hidden = button.selected;
    button.selected = !button.selected;
    self.isNeedShowHistogram = button.selected;
}

- (void)sliderValueTouchUp:(UISlider *)slider {
    [self refreshShutterAndIso];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    CGPoint point = [[touches anyObject] locationInView:self.preview];
    CGPoint focusPoint = CGPointMake(point.x/self.preview.width, point.y/self.preview.height);
    NSLog(@"focusPoint：%@",NSStringFromCGPoint(focusPoint));
    NSError *error;
    if ([self.capturePipeline.videoDevice lockForConfiguration:&error]) {
        
        ///焦点位置
        if (self.capturePipeline.videoDevice.isFocusPointOfInterestSupported) {
            [self.capturePipeline.videoDevice setFocusPointOfInterest:focusPoint];
        }else{
            NSLog(@"聚焦失败");
        }

        // 聚焦模式
        if ([self.capturePipeline.videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.capturePipeline.videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }else{
            NSLog(@"聚焦‘模式’修改失败");
        }

        ///曝光
        if (self.capturePipeline.videoDevice.isExposurePointOfInterestSupported) {
            [self.capturePipeline.videoDevice setExposurePointOfInterest:focusPoint];
            [self.capturePipeline.videoDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            NSLog(@"曝光修改失败");
        }
        
        [self.capturePipeline.videoDevice unlockForConfiguration];
    }

}

#pragma mark - < delegate >
- (void)capturePipelineDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self refreshWhitebalance];
    NSArray *arr;
    if (self.isNeedShowHistogram) {
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        arr = [self.lineHistogram brightnessFromPixelBuffer:pixelBuffer];
//        arr = [self.lineHistogram brightnessWithVImageFromPixelBuffer:pixelBuffer];//方案可行，计算可能哪里出问题了，性能也不错，才54%
    }
    static BOOL isSkip = NO;//增加‘跳帧’，优化方向还可以是：压缩图片。
    if (!isSkip) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.captureBtn.selected && arr) {
                [self.lineCharView removeAllChartDatas];
                [self.lineCharView addChartData:arr];
                [self.lineCharView drawChartWithAnimationDisplay:NO];
            }
        });
    }
    isSkip = !isSkip;
    
}

- (void)capturePipelineDidCapturePhoto:(AVCapturePhoto *)photo {
    NSData *data = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData:data];
    UIImage *resultImage = [self drawWaterMarkWithImage:image];
    [self saveToAlbumWithImage:resultImage];
}

#pragma mark - < refresh >
- (void)refreshWhitebalance {
    //这个方法非常耗CPU，能增加30%，在7plus上。
    dispatch_async(dispatch_get_main_queue(), ^{
        float maxgain = [self.capturePipeline.videoDevice maxWhiteBalanceGain];
        
        //CCT是correlated colour temperature的缩写，意思是相关色温。
        AVCaptureWhiteBalanceGains whiteBalanceGain = self.capturePipeline.videoDevice.deviceWhiteBalanceGains;
        AVCaptureWhiteBalanceTemperatureAndTintValues temperature = [self.capturePipeline.videoDevice temperatureAndTintValuesForDeviceWhiteBalanceGains:whiteBalanceGain];
        NSString *result = [NSString stringWithFormat:@"白平衡：\nR:%.2f,\nG:%.2f,\nB:%.2f,\nCCT:%.2f,\ntint:%.2f",whiteBalanceGain.redGain,whiteBalanceGain.greenGain,whiteBalanceGain.blueGain,temperature.temperature,temperature.tint];
        self.gainView.text = result;
        
        AVCaptureWhiteBalanceGains grayBalanceGain = self.capturePipeline.videoDevice.grayWorldDeviceWhiteBalanceGains;
        AVCaptureWhiteBalanceGains suitableGain = {MIN(grayBalanceGain.redGain, maxgain), MIN(grayBalanceGain.greenGain, maxgain), MIN(grayBalanceGain.blueGain, maxgain)};
        AVCaptureWhiteBalanceTemperatureAndTintValues grayTemperature = [self.capturePipeline.videoDevice temperatureAndTintValuesForDeviceWhiteBalanceGains:suitableGain];
        NSString *grayResult = [NSString stringWithFormat:@"灰•白平衡：\nR:%.2f,\nG:%.2f,\nB:%.2f,\nCCT:%.2f,\ntint:%.2f",suitableGain.redGain,suitableGain.greenGain,suitableGain.blueGain,grayTemperature.temperature,grayTemperature.tint];
        self.grayGainView.text = grayResult;
    });
}

- (void)refreshShutterAndIso {
    NSError *error;
    if ([self.capturePipeline.videoDevice lockForConfiguration:&error]) {
        ///ISO
        CGFloat isoSliderValue = self.ISOSlider.value;
        CGFloat minISO = self.capturePipeline.videoDevice.activeFormat.minISO;
        CGFloat maxISO = self.capturePipeline.videoDevice.activeFormat.maxISO;
        CGFloat currentISO = (maxISO - minISO) * isoSliderValue + minISO;
        
        CGFloat durationSliderValue = self.shutterSlider.value;
        CMTime minDuration = self.capturePipeline.videoDevice.activeFormat.minExposureDuration;
        CMTime maxDuration = self.capturePipeline.videoDevice.activeFormat.maxExposureDuration;
        int32_t denominator = maxDuration.timescale * minDuration.timescale;
        
        int32_t minValue = (int32_t)minDuration.value * maxDuration.timescale;
        int32_t maxValue = (int32_t)maxDuration.value * minDuration.timescale;
        CGFloat currentDuration = (maxValue - minValue) * durationSliderValue + minValue;
        CMTime duration = CMTimeMake(currentDuration, denominator);//这里精度在极值情况可能有问题
//        duration = AVCaptureExposureDurationCurrent;//一般为cmtime(0,0)
        //这是设置曝光时间和ISO的唯一方法
        [self.capturePipeline.videoDevice setExposureModeCustomWithDuration:duration ISO:currentISO completionHandler:^(CMTime syncTime) {
            NSLog(@"%lld, %d",syncTime.value,syncTime.timescale);
        }];
        
        [self.capturePipeline.videoDevice unlockForConfiguration];
        
        self.shutterLabel.text = [NSString stringWithFormat:@"shutter range(%.2f~%.2f)：%.3f秒",(CGFloat)minDuration.value/minDuration.timescale,(CGFloat)maxDuration.value/maxDuration.timescale,(CGFloat)duration.value/duration.timescale];
        self.ISOLabel.text = [NSString stringWithFormat:@"ISO range(%.0f~%.0f)：%.0f",minISO,maxISO,currentISO];
    }
}

#pragma mark - < save photo >
//使用该方法不会模糊，根据屏幕密度计算
- (UIImage *)drawWaterMarkWithImage:(UIImage *)image {
    NSString *gainText = self.gainView.text;
    NSString *grayGainText = self.grayGainView.text;
    
    UIGraphicsBeginImageContext(image.size);
    //绘制上下文：1.绘制图片
    [image drawAtPoint:CGPointMake(0, 20)];
    //绘制上下文：2.添加文字到上下文
    NSDictionary *dict=@{NSFontAttributeName:[UIFont systemFontOfSize:30.0],
                         NSForegroundColorAttributeName:[UIColor redColor],
//                         NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:10]
                         };
    [gainText drawAtPoint:CGPointMake(30, 60) withAttributes:dict];
    [grayGainText drawAtPoint:CGPointMake(30, 360) withAttributes:dict];
    UIImage *watermarkImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return watermarkImage;
}

- (void)saveToAlbumWithImage:(UIImage *)image {
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSString *msg = success ? @"已经保存到相册" : @"未能保存到相册";
        dispatch_async(dispatch_get_main_queue(), ^{
            [EasyProgress showSuccess:msg];
        });
    }];
}



#pragma mark - < init >
- (void)setupSubview {
    CGFloat width = KScreenWidth;
    CGFloat height = width / (480/640.0);
    self.preview = [[CameraPreview alloc]init];
    [self.view addSubview:self.preview];
    [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.width.equalTo(@(width));
        make.height.equalTo(@(height));
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"< Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.width.equalTo(@80);
        make.height.equalTo(@44);
    }];
    
    self.gainView = [[UITextView alloc]init];
    self.gainView.layer.borderWidth = 1;
    self.gainView.textColor = [UIColor redColor];
    self.gainView.editable = NO;
    self.gainView.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.gainView];
    [self.gainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(4);
        make.width.equalTo(self.view).multipliedBy(0.24);
        make.top.equalTo(self.preview.mas_bottom);
        make.height.equalTo(@96);
    }];
    
    self.grayGainView = [[UITextView alloc]init];
    self.grayGainView.layer.borderWidth = 1;
    self.grayGainView.textColor = [UIColor redColor];
    self.grayGainView.editable = NO;
    self.grayGainView.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.grayGainView];
    [self.grayGainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gainView.mas_right).offset(4);
        make.width.top.height.equalTo(self.gainView);
    }];
    
    [self.view addSubview:self.shutterLabel];
    
    ///快门，（也就是设置曝光时间？）
    self.shutterSlider = [[UISlider alloc]init];
    self.shutterSlider.minimumValue = 0;
    self.shutterSlider.maximumValue = 0.99;
    [self.shutterSlider addTarget:self action:@selector(sliderValueTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shutterSlider];
    [self.shutterSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-4);
        make.top.equalTo(self.gainView.mas_bottom).offset(4);
        make.height.equalTo(@30);
    }];
    
    [self.shutterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.shutterSlider);
        make.top.equalTo(self.shutterSlider.mas_bottom).offset(-10);
        make.height.equalTo(@15);
    }];
    
    [self.view addSubview:self.ISOLabel];
    
    self.ISOSlider = [[UISlider alloc]init];
    self.ISOSlider.minimumValue = 0;
    self.ISOSlider.maximumValue = 1;
    [self.ISOSlider addTarget:self action:@selector(sliderValueTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.ISOSlider];
    [self.ISOSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.grayGainView.mas_right).offset(4);
        make.right.equalTo(self.view).offset(-4);
        make.top.equalTo(self.grayGainView).offset(10);
        make.height.equalTo(@(30));
    }];
    
    [self.ISOLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.ISOSlider);
        make.top.equalTo(self.ISOSlider.mas_bottom).offset(-6);
        make.height.equalTo(@15);
    }];
    
    [self.view addSubview:self.apertureLabel];
    [self.apertureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.shutterLabel);
        make.top.equalTo(self.shutterLabel.mas_bottom);
    }];
    
    _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _captureBtn.layer.borderWidth = 1;
    _captureBtn.layer.borderColor = [UIColor redColor].CGColor;
    _captureBtn.layer.cornerRadius = 40;
    [_captureBtn setTitle:@"亮度" forState:UIControlStateNormal];
    [_captureBtn setTitle:@"隐藏亮度" forState:UIControlStateSelected];
    [_captureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_captureBtn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureBtn];
    [_captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.preview).offset(-10);
        make.width.height.equalTo(@80);
    }];
    
    [self.view addSubview:self.lineCharView];
    [self.lineCharView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.preview.mas_bottom);
    }];
}

- (UILabel *)shutterLabel {
    if (_shutterLabel == nil) {
        _shutterLabel = [[UILabel alloc]init];
        _shutterLabel.text = @"shutter range";
        _shutterLabel.textAlignment = NSTextAlignmentCenter;
        _shutterLabel.font = [UIFont systemFontOfSize:12];
        _shutterLabel.textColor = [UIColor redColor];
    }
    return _shutterLabel;
}

- (UILabel *)ISOLabel {
    if (_ISOLabel == nil) {
        _ISOLabel = [[UILabel alloc]init];
        _ISOLabel.text = @"ISO";
        _ISOLabel.textAlignment = NSTextAlignmentCenter;
        _ISOLabel.font = [UIFont systemFontOfSize:12];
        _ISOLabel.textColor = [UIColor redColor];
    }
    return _ISOLabel;
}

- (UILabel *)apertureLabel {
    if (_apertureLabel == nil) {
        _apertureLabel = [[UILabel alloc]init];
        _apertureLabel.text = @"光圈：只读";
        _apertureLabel.textAlignment = NSTextAlignmentLeft;
        _apertureLabel.font = [UIFont systemFontOfSize:12];
        _apertureLabel.textColor = [UIColor redColor];
    }
    return _apertureLabel;
}

@end
