//
//  CameraPreview.h
//  Poppy_Dev01
//
//  Created by jf on 2020/8/24.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraPreview : UIView

@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;

@end

NS_ASSUME_NONNULL_END
