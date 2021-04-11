//
//  VideoRecorderCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/10.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoRecorderCtl.h"
#import "DrawingBoardView.h"
#import <MSWeakTimer.h>
#import "ScreenRecorder.h"
#import "MediaRecorder.h"
#import "EasyGraphicsRender.h"
#import "CheckAuthorization.h"
#import <Photos/Photos.h>
#import "Lottie.h"
#import "TestLayerView.h"

@interface VideoRecorderCtl ()

@property(nonatomic, strong)DrawingBoardView *drawView;
@property(nonatomic, strong)UIButton *startRecordBtn;
@property(nonatomic, strong)UILabel *timeLabel;
@property(nonatomic, strong)UISlider *slider;
@property(nonatomic, strong)LOTAnimationView *lotView;
@property(nonatomic, strong)TestLayerView *testLayerView;

@property(nonatomic, strong)MSWeakTimer *timer;
@property(nonatomic, assign)int duration;



@end

@implementation VideoRecorderCtl

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    
    EasyGraphicsRender *render = [[EasyGraphicsRender alloc]init];
    [render runDrawingActions:^(__kindof UIGraphicsRendererContext * _Nonnull rendererContext) {
        
    } completionActions:^(__kindof UIGraphicsRendererContext * _Nonnull rendererContext) {
        
    } error:nil];
    
    [CheckAuthorization checkAlbumAuthorizationStatus:^(BOOL result) {
        if (result) {
        }else {
        }
    }];
}

#pragma mark - < event >
- (void)sliderValueChange:(UISlider *)slider {
    NSLog(@"%f",slider.value);
    self.lotView.animationProgress = fabs(slider.value);
}

- (void)startRecordBtnEvent:(UIButton *)button {
//    [self screenRecorder_old:button];
    [self mediaRecorder_new:button];
    button.selected = !button.selected;
}

- (void)countdownEvent:(MSWeakTimer *)timer {
    
    
    
    self.duration++;
    [self showTime];
    NSLog(@"%@",self.timeLabel.text);
    
    
//    CGFloat width = 2 * self.duration;
//    UIImage *tmp = [EasyGraphicsRender resizeImage:[UIImage imageNamed:@"bgPic"] size:CGSizeMake(width, width)];
//    [self saveToAlbum:tmp];
}

- (void)screenRecorder_old:(UIButton *)button {
    if (!button.selected) {
        //开始录制
        self.duration = 0;
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownEvent:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [self.timer fire];
        [[ScreenRecorder sharedInstance]startRecording];
        [ScreenRecorder sharedInstance].recorderView = self.lotView;
        [ScreenRecorder sharedInstance].finishBlock = ^(NSString *videoPath) {
            NSLog(@"录制完成，视频沙盒地址：%@",videoPath);
        };
    }else {
        //结束录制
        [self.timer invalidate];
        [[ScreenRecorder sharedInstance]stopRecording];
    }
}

//整理后的录制类
- (void)mediaRecorder_new:(UIButton *)button {
    if (!button.selected) {
        //开始录制
        self.duration = 0;
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownEvent:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [self.timer fire];
        
        [[MediaRecorder sharedInstance] startWithRecorderView:self.view];
        [MediaRecorder sharedInstance].finishBlock = ^(NSString *videoPath) {
            NSLog(@"录制完成，视频沙盒地址：%@",videoPath);
        };
    }else {
        //结束录制
        [self.timer invalidate];
        [[MediaRecorder sharedInstance]stopRecording];
    }
}

- (void)saveToAlbum:(UIImage *)image {
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSString *msg = success ? @"已经保存到相册" : @"未能保存视频到相册";
        NSLog(@"%@",msg);
    }];
}

#pragma mark - < private >
- (void)showTime {
    NSString *min = [NSString stringWithFormat:@"%d",self.duration/60];
    NSString *sec = [NSString stringWithFormat:@"%d",self.duration % 60];
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",[self suitable:min],[self suitable:sec]];
}

- (NSString *)suitable:(NSString *)value {
    if (value.length == 1) {
        return [NSString stringWithFormat:@"0%@",value];
    }
    return value;
}

- (NSArray *)getLottiesPath {
    NSString *bundlePath = [[ NSBundle mainBundle] pathForResource:@"lotties" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSArray *lotties = [bundle pathsForResourcesOfType:@"" inDirectory:@""];
    return lotties;
}

#pragma mark - < init >
- (void)setupSubviews {
    
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@64);
        make.height.equalTo(@(30));
    }];
    
    [self.view addSubview:self.startRecordBtn];
    [self.startRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-70);
        make.width.equalTo(@80);
        make.height.equalTo(@(40));
    }];
    
    self.drawView = [[DrawingBoardView alloc]init];
    self.drawView.layer.borderWidth = 1;
    [self.view addSubview:self.drawView];
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.startRecordBtn.mas_top).offset(-5);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(3);
    }];
    
    [self.view addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-15);
        make.width.equalTo(@300);
        make.height.equalTo(@(35));
    }];
    
    self.lotView = [[LOTAnimationView alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[self getLottiesPath][0]]];
    self.lotView.loopAnimation = true;
//    self.lotView.animationSpeed = 0;
//    self.lotView.frame = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:self.lotView];
    [self.lotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.drawView);
        make.width.height.equalTo(@(100));
    }];
    
    [self.lotView playWithCompletion:^(BOOL animationFinished) {
        
    }];
    
//    self.testLayerView.hidden = !true;
    [self.view addSubview:self.testLayerView];
    [self.testLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.drawView);
    }];
}

- (UIButton *)startRecordBtn {
    if (_startRecordBtn == nil) {
        _startRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startRecordBtn setTitle:@"开始录制" forState:UIControlStateNormal];
        [_startRecordBtn setTitle:@"结束录制" forState:UIControlStateSelected];
        [_startRecordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startRecordBtn addTarget:self action:@selector(startRecordBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        _startRecordBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_startRecordBtn];
        
    }
    return _startRecordBtn;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [[UIColor redColor]colorWithAlphaComponent:0.85];
    }
    return _timeLabel;
}

- (UISlider *)slider {
    if (_slider == nil) {
        _slider = [[UISlider alloc]init];
        _slider.minimumValue = -1;
        _slider.maximumValue = 1;
        [_slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (TestLayerView *)testLayerView {
    if (_testLayerView == nil) {
        _testLayerView = [[TestLayerView alloc]init];
    }
    return _testLayerView;
}

@end
