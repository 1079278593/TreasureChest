//
//  CameraPreview.m
//  Poppy_Dev01
//
//  Created by jf on 2020/8/24.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "CameraPreview.h"

@interface CameraPreview ()



@end

@implementation CameraPreview

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)init {
    if(self == [super init]){
        self.previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    }
    return self;
}

- (void)initView {
    
}

- (void)dealloc
{
    NSLog(@"CameraPreview dealloc");
}

@end
