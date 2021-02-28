//
//  LottieLoader.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/27.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "LottieLoader.h"
#import "Lottie.h"
#import "LOTCompositionContainer.h"
#import "ImageConvertor.h"

@interface LottieLoader ()

@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)LOTComposition *sceneModel;
@property(nonatomic, strong)LOTCompositionContainer *compContainer;

@end

@implementation LottieLoader

- (CVPixelBufferRef)pixelBufferFromLottiePath:(NSString *)path url:(NSString *)url progress:(CGFloat)progress {
    if (![self.url isEqualToString:url]) {
        self.url = url;
        NSLog(@"lottie loader url:%@, path:%@",url,path);
        _sceneModel = [LOTComposition animationWithFilePath:path];
        self.compContainer = [[LOTCompositionContainer alloc] initWithModel:nil inLayerGroup:nil withLayerGroup:_sceneModel.layerGroup withAssestGroup:_sceneModel.assetGroup];
    }
    
    NSNumber *currentFrame = [self frameForProgress:progress sceneModel:_sceneModel];
    [self setLayerToFrame:currentFrame];
    CVPixelBufferRef buffer = [ImageConvertor pixelBufferLeftLandscapeFromLayer:_compContainer frameSize:CGSizeMake(640, 480)];
    return buffer;
}

- (NSTimeInterval)getDuration {
    return self.sceneModel.timeDuration;
}

#pragma mark - < private >
- (void)setLayerToFrame:(NSNumber *)currentFrame {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _compContainer.currentFrame = currentFrame;
    [_compContainer setNeedsDisplay];
    [CATransaction commit];
}

- (NSNumber *)frameForProgress:(CGFloat)progress sceneModel:(LOTComposition *)sceneModel {
  if (!_sceneModel) {
    return @0;
  }
  return @(((_sceneModel.endFrame.floatValue - _sceneModel.startFrame.floatValue) * progress) + _sceneModel.startFrame.floatValue);
}
                                                              
@end
