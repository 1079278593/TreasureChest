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

@interface WhiteBalanceController () <CapturePipelineDelegate>

@property(nonatomic, strong)CapturePipeline *capturePipeline;
@property(nonatomic, strong)CameraPreview *preview;
@property(nonatomic, strong)UILabel *gainView;
@property(nonatomic, strong)UILabel *grayGainView;

@end

@implementation WhiteBalanceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubview];
    
    self.capturePipeline = [[CapturePipeline alloc]init];
    self.capturePipeline.delegate = self;
    self.capturePipeline.sessionPreset = AVCaptureSessionPreset1280x720;
    self.capturePipeline.devicePostion = AVCaptureDevicePositionBack;
    self.capturePipeline.orientation = UIInterfaceOrientationPortrait;
    [self.capturePipeline prepareRunning];
    [self.capturePipeline startRunning];
    self.preview.previewLayer.session = self.capturePipeline.captureSession;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderWidth = 1;
    [button setTitle:@"拍照" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self.view);
        make.width.height.equalTo(@80);
    }];
    
    
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
//    UIImage *image = [self convertViewToImage:self.view];
//    [self saveToAlbumWithImage:image];
    [self.capturePipeline capturePhoto];
}

#pragma mark - < delegate >
- (void)capturePipelineDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    dispatch_async(dispatch_get_main_queue(), ^{
        float maxgain = [self.capturePipeline.videoDevice maxWhiteBalanceGain];
        
        AVCaptureWhiteBalanceGains whiteBalanceGain = self.capturePipeline.videoDevice.deviceWhiteBalanceGains;
        AVCaptureWhiteBalanceTemperatureAndTintValues temperature = [self.capturePipeline.videoDevice temperatureAndTintValuesForDeviceWhiteBalanceGains:whiteBalanceGain];
        NSString *result = [NSString stringWithFormat:@"balance gains:\n red: %f\n green: %f\n blue: %f\n temperature:%f\n tint:%f",whiteBalanceGain.redGain,whiteBalanceGain.greenGain,whiteBalanceGain.blueGain,temperature.temperature,temperature.tint];
        self.gainView.text = result;
        
        
        AVCaptureWhiteBalanceGains grayBalanceGain = self.capturePipeline.videoDevice.grayWorldDeviceWhiteBalanceGains;
        AVCaptureWhiteBalanceGains suitableGain = {MIN(grayBalanceGain.redGain, maxgain), MIN(grayBalanceGain.greenGain, maxgain), MIN(grayBalanceGain.blueGain, maxgain)};
        AVCaptureWhiteBalanceTemperatureAndTintValues grayTemperature = [self.capturePipeline.videoDevice temperatureAndTintValuesForDeviceWhiteBalanceGains:suitableGain];
        NSString *grayResult = [NSString stringWithFormat:@"gray balance gains:\n red: %f\n green: %f\n blue: %f\n temperature:%f\n tint:%f",suitableGain.redGain,suitableGain.greenGain,suitableGain.blueGain,grayTemperature.temperature,grayTemperature.tint];
        self.grayGainView.text = grayResult;
    });
}

- (void)capturePipelineDidCapturePhoto:(AVCapturePhoto *)photo {
    NSData *data = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData:data];
    UIImage *resultImage = [self image:image addWaterMarkWithString:@""];
    [self saveToAlbumWithImage:resultImage];
}

#pragma mark - < save photo >
//使用该方法不会模糊，根据屏幕密度计算
- (UIImage *)image:(UIImage *)image addWaterMarkWithString:(NSString *)string{
    //开启一个图形上下文
    UIGraphicsBeginImageContext(image.size);
    //绘制上下文：1.绘制图片
    [image drawAtPoint:CGPointMake(0, 20)];
    //绘制上下文：2.添加文字到上下文
    NSDictionary *dict=@{NSFontAttributeName:[UIFont systemFontOfSize:30.0],
                         NSForegroundColorAttributeName:[UIColor redColor],
//                         NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:10]
                         };
    [self.gainView.text drawAtPoint:CGPointMake(30, 60) withAttributes:dict];
    [self.grayGainView.text drawAtPoint:CGPointMake(30, 360) withAttributes:dict];
    //从图形上下文中获取合成的图片
    UIImage *watermarkImage=UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    return watermarkImage;
}

- (void)saveToAlbumWithImage:(UIImage *)image {
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        //            dispatch_async(dispatch_get_main_queue(), ^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //            });
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSString *msg = success ? @"已经保存到相册" : @"未能保存到相册";
        dispatch_async(dispatch_get_main_queue(), ^{
            [EasyProgress showSuccess:msg];
        });
    }];
}

#pragma mark - < init >
- (void)setupSubview {
    self.preview = [[CameraPreview alloc]init];
    self.preview.frame = self.view.frame;
    [self.view addSubview:self.preview];
    
    self.gainView = [[UILabel alloc]init];
    self.gainView.layer.borderWidth = 1;
    self.gainView.textColor = [UIColor redColor];
    self.gainView.numberOfLines = 6;
    self.gainView.font = [UIFont systemFontOfSize:19];
    [self.view addSubview:self.gainView];
    self.gainView.frame = CGRectMake(20, 69, 300, 140);
    
    self.grayGainView = [[UILabel alloc]init];
    self.grayGainView.layer.borderWidth = 1;
    self.grayGainView.textColor = [UIColor redColor];
    self.grayGainView.numberOfLines = 6;
    self.grayGainView.font = [UIFont systemFontOfSize:19];
    [self.view addSubview:self.grayGainView];
    self.grayGainView.frame = CGRectMake(20, self.gainView.bottom+10, 300, 140);
}

@end