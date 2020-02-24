//
//  URLSessionTaskCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "URLSessionTaskCtl.h"

@interface URLSessionTaskCtl ()<NSURLSessionDelegate>

@property(nonatomic, strong)UIImageView *resourceCover;
@property(nonatomic, strong)UIButton *loadButton;
@property(nonatomic, strong)UIButton *cancelButton;
@property(nonatomic, strong)UISlider *slider;

@end

@implementation URLSessionTaskCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (void)loadBtnEvent:(UIButton *)button {
    if (button.selected) {
        [self.dataTask suspend];
        [self.loadButton setTitle:@"暂停状态" forState:UIControlStateNormal];
    }else {
        [self.dataTask resume];
        [self.loadButton setTitle:@"下载状态" forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
}

- (void)cancelBtnEvent:(UIButton *)button {
    
}

#pragma mark - < delegate >
//1.接收服务器的响应，默认取消该请求
//completionHandler 回调 传给系统
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    if (self.currentSize == 0) {
        [[NSFileManager defaultManager] createFileAtPath:self.fullPath contents:nil attributes:nil];
    }
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_fullPath];
    self.totalSize = response.expectedContentLength+self.currentSize;
    completionHandler(NSURLSessionResponseAllow);
}

//2.收到返回数据，多次调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    self.currentSize += data.length;
    CGFloat progress = 1.0 * self.currentSize / self.totalSize;
    self.slider.value = progress;
    NSLog(@"%.2f %%",100.0*progress);
}
//3.请求结束或失败时调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    NSLog(@"didCompleteWithError:%@",_fullPath);
}


#pragma mark - < getter and setter >
-(NSURLSessionDataTask *)dataTask{
    if (_dataTask == nil) {
        NSString *url = @"https://gss3.baidu.com/6LZ0ej3k1Qd3ote6lo7D0j9wehsv/tieba-smallvideo-transcode/32099007_049d90cbaf0d8e06cabcb198ce36b4eb_52d6d309_2.mp4";
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fullPath error:nil];
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentSize];
        [request setValue:range forHTTPHeaderField:@"Range"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _dataTask = [session dataTaskWithRequest:request];
        
        self.currentSize = [[fileDict valueForKey:@"NSFileSize"] integerValue];
    }
    return _dataTask;
}

-(NSString *)fullPath{
    if (_fullPath == nil) {
        _fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"1234.mp4"];
    }
    return _fullPath;
}

@end
