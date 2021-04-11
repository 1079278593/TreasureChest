//
//  URLSessionTaskCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "URLSessionTaskCtl.h"
#import "URLDownloadTask.h"
#import "URLOfflineDownloadTask.h"
#import "VideoPlayerSampleView.h"

#define VIDEOURL1 @"http://video.yuntoo.com/dist/ab7b54f3-8df0-4678-babc-15a6e4f642b7.mp4"
#define VIDEOURL2 @"https://gss3.baidu.com/6LZ0ej3k1Qd3ote6lo7D0j9wehsv/tieba-smallvideo-transcode/32099007_049d90cbaf0d8e06cabcb198ce36b4eb_52d6d309_2.mp4"
@interface URLSessionTaskCtl ()

@property(nonatomic, strong)UIImageView *resourceCover;
@property(nonatomic, strong)UIButton *loadButton;
@property(nonatomic, strong)UIButton *cancelButton;
@property(nonatomic, strong)UISlider *slider;

@property(nonatomic, strong)NSString *destinationFullPath;
@property(nonatomic, strong)URLOfflineDownloadTask *offlineDownloadTask;
@property(nonatomic, strong)URLDownloadTask *downloadTask;
@property(nonatomic, strong)VideoPlayerSampleView *videoView;

@end

@implementation URLSessionTaskCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self downloadConfig];
    [self downloadBlockCall];
    [self offlineDownloadBlockCall];
}

- (void)setupSubviews {
    
    self.resourceCover = [[UIImageView alloc]init];
    self.resourceCover.image = [UIImage imageNamed:@"testIcon2"];
    self.resourceCover.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.resourceCover];
    [self.resourceCover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@80);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@80);
    }];
    self.resourceCover.layer.borderWidth = 1;
    
    self.loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loadButton setTitle:@"下载" forState:UIControlStateNormal];
    [self.loadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.loadButton addTarget:self action:@selector(loadBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loadButton];
    [self.loadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resourceCover.mas_bottom).offset(40);
        make.right.equalTo(self.resourceCover.mas_centerX).offset(-10);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
    }];

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadButton);
        make.left.equalTo(self.resourceCover.mas_centerX).offset(10);
        make.width.height.equalTo(self.loadButton);
    }];
    
    self.slider = [[UISlider alloc]init];
    self.slider.enabled = false;
    self.slider.tintColor = [UIColor redColor];
    [self.view addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resourceCover.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
        make.height.equalTo(@30);
    }];
    
    self.videoView = [[VideoPlayerSampleView alloc]init];
    self.videoView.frame = CGRectMake(0, 64, KScreenWidth, 300);
    self.videoView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.videoView.layer.borderWidth = 1;
    [self.view addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadButton.mas_bottom).offset(40);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(@230);
    }];
    self.videoView.hidden = true;
}

#pragma mark - <  >
- (void)downloadConfig {
    
    self.destinationFileName = @"1234.mp4";
    _destinationFullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.destinationFileName];
    NSLog(@"目标目录：%@",_destinationFullPath);
    
    //方式1：离线断点
//    self.offlineDownloadTask = [[URLOfflineDownloadTask alloc]init];
//    [self.offlineDownloadTask setupTask:VIDEOURL2 localPath:_destinationFullPath];
        
    //方式2：
    self.downloadTask = [[URLDownloadTask alloc]init];
    [self.downloadTask setupTask:VIDEOURL2 localPath:_destinationFullPath];
    
    //方式3：简单方式
//    self.downloadTask = [[URLDownloadTask alloc]init];
//    [self.downloadTask easyDownload:VIDEOURL2 localPath:_destinationFullPath];
}

#pragma mark - < button event >
- (void)loadBtnEvent:(UIButton *)button {
    //1
//    if (button.selected) {
//        [self.offlineDownloadTask pauseDownload];
//    }else {
//        [self.offlineDownloadTask continueDownload];
//    }
    
    //2
    if (button.selected) {
        [self.downloadTask pauseDownload];
    }else {
        [self.downloadTask continueDownload];
    }
    
    [button setTitle:(button.selected ? @"暂停中" : @"下载中") forState:UIControlStateNormal];
    button.selected = !button.selected;
}

- (void)cancelBtnEvent:(UIButton *)button {
    [self.downloadTask stopDownload];
}

- (void)offlineDownloadBlockCall {
    @weakify(self);
    self.offlineDownloadTask.progressBlock = ^(CGFloat progress) {
        @strongify(self)
        self.slider.value = progress;
        
        if (progress >= 1) {
            self.videoView.hidden = false;
            [self.videoView setupPlayer:self.destinationFullPath];
        }
    };
    
    self.offlineDownloadTask.failBlock = ^{
        
    };
}

- (void)downloadBlockCall {
    @weakify(self);
    self.downloadTask.progressBlock = ^(CGFloat progress) {
        @strongify(self)
        self.slider.value = progress;
        
        if (progress >= 1) {
            self.videoView.hidden = false;
            [self.videoView setupPlayer:self.destinationFullPath];
        }
    };
    
    self.downloadTask.failBlock = ^{
        
    };
}

@end
