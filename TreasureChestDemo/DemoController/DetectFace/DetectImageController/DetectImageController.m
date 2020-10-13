//
//  DetectImageController.m
//  TreasureChest
//
//  Created by jf on 2020/10/13.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "DetectImageController.h"
#import <Vision/Vision.h>

typedef void(^CompletionHandler)(VNRequest * _Nullable request, NSError * _Nullable error);

@interface DetectImageController ()

@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIButton *button;

@end

@implementation DetectImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

#pragma mark - < event >
- (void)buttonEvent:(UIButton *)button {
    
    
    // 转换CIImage
    CIImage *convertImage = [[CIImage alloc]initWithImage:self.imageView.image];
    
    // 处理单一图片使用 VNImageRequestHandler，处理图片序列使用 VNSequenceRequestHandler
    // 如果我们使用的是 VNImageRequestHandler，那么在初始化时就提供需要处理的图片，初始化以后使用 perform(_:) 方法执行我们的 Request
    VNImageRequestHandler *detectRequestHandler = [[VNImageRequestHandler alloc]initWithCIImage:convertImage options:@{}];
    
    
    
    // 设置回调
    CompletionHandler completionHandler = ^(VNRequest *request, NSError * _Nullable error) {
        
        
        NSArray *observations = request.results;
        [[self class] faceLandmarks:observations];
        
    };
    
    
    
    // 创建BaseRequest
    VNImageBasedRequest *detectRequest = [[VNDetectFaceLandmarksRequest alloc]initWithCompletionHandler:completionHandler];
    
    CFTimeInterval startTime = CACurrentMediaTime();
    // 发送识别请求：传入数组
    [detectRequestHandler performRequests:@[detectRequest] error:nil];
    
    CFTimeInterval inferenceTime = (CACurrentMediaTime() - startTime) * 1000;NSLog(@"duration: %f",inferenceTime);
    
}

#pragma mark - < private >
// 处理人脸特征回调:这个方法内最多0.2ms
+ (void)faceLandmarks:(NSArray *)observations {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (VNFaceObservation *observation  in observations) {
        // 获取细节特征
        VNFaceLandmarks2D *landmarks = observation.landmarks;
        [array addObject:landmarks];
        [self getAllkeyWithClass:[VNFaceLandmarks2D class] isProperty:YES block:^(NSString *key) {
           // 过滤属性
           if ([key isEqualToString:@"allPoints"]) {
               return;
           }
            
           // 得到对应细节具体特征（鼻子，眼睛。。。）
           VNFaceLandmarkRegion2D *region2D = [landmarks valueForKey:key];
            
           // 特征存储对象进行存储
//            NSLog(@"region2D %@",region2D);
//           [detectFaceData setValue:region2D forKey:key];
//           [detectFaceData.allPoints addObject:region2D];
        }];
    }
}

// 获取对象属性keys
+ (NSArray *)getAllkeyWithClass:(Class)class isProperty:(BOOL)property block:(void(^)(NSString *key))block{
//    CFTimeInterval startTime = CACurrentMediaTime();
    
    NSMutableArray *keys = @[].mutableCopy;
    unsigned int outCount = 0;
    
    Ivar *vars = NULL;
    objc_property_t *propertys = NULL;
    const char *name;
    
    if (property) {
        propertys = class_copyPropertyList(class, &outCount);
    }else{
        vars = class_copyIvarList(class, &outCount);
    }
    
    for (int i = 0; i < outCount; i ++) {
        
        if (property) {
            objc_property_t property = propertys[i];
            name = property_getName(property);
        }else{
            Ivar var = vars[i];
            name = ivar_getName(var);
        }
        
        NSString *key = [NSString stringWithUTF8String:name];
        block(key);
    }
    free(vars);
//    CFTimeInterval inferenceTime = (CACurrentMediaTime() - startTime) * 1000;
//    NSLog(@"duration: %f",inferenceTime);
    return keys.copy;
}

#pragma mark - < init view >
- (void)initView {
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.equalTo(self.view).multipliedBy(0.7);
    }];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setTitle:@"检测" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.imageView.mas_bottom).offset(10);
        make.width.equalTo(@70);
        make.height.equalTo(@45);
    }];
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [UIImage imageNamed:@"face3"];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end
