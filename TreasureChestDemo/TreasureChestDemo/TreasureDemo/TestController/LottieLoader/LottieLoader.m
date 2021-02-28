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

@property(nonatomic, assign)CGSize lottieViewSize;
@property(nonatomic, strong)LOTComposition *sceneModel;
@property(nonatomic, strong)LOTCompositionContainer *compContainer;

@end

@implementation LottieLoader

- (instancetype)initWithPath:(NSString *)path {
    if(self == [super init]){
        self.path = path;
        [self lottieLoadWithLocalPath:path];
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)url {
    if(self == [super init]){
        self.url = url;
        [self lottieLoadWithUrl:url];
    }
    return self;
}

#pragma mark - < public >
- (CVPixelBufferRef)pixelBufferWithProgress:(CGFloat)progress {
    [self lottieReload];
    if (![self isGenerateFinish] || self.buffers.count == 0) {
        return NULL;
    }
    
    NSUInteger index = (self.buffers.count - 1) * progress;
    NSLog(@"bufferCount%lu  index:%lu",self.buffers.count,index);
    return self.buffers[index].buffer;
}

- (CVPixelBufferRef)pixelBufferWithProgress11:(CGFloat)progress {
    NSNumber *currentFrame = [self frameForProgress:progress sceneModel:_sceneModel];
    [self setLayerToFrame:currentFrame];
    CVPixelBufferRef buffer = [ImageConvertor pixelBufferLeftLandscapeFromLayer:_compContainer frameSize:self.lottieViewSize];
    return buffer;
}

- (UIImage *)imageWithProgress:(CGFloat)progress {
    NSNumber *currentFrame = [self frameForProgress:progress sceneModel:_sceneModel];
    [self setLayerToFrame:currentFrame];
    UIImage *image = [ImageConvertor imageFromLayer:self.compContainer frameSize:CGSizeMake(480, 640)];
    return image;
}

- (NSTimeInterval)getDuration {
    return self.sceneModel.timeDuration;
}

- (void)clean {
    for (TextureModel *buffer in self.buffers) {
        CFRelease(buffer.buffer);
    }
    self.buffers = nil;
}

#pragma mark - < load >
- (void)lottieLoadWithLocalPath:(NSString *)path {
    _sceneModel = [LOTComposition animationWithFilePath:path];
    if (_sceneModel) {
        self.lottieViewSize = _sceneModel.compBounds.size;
        _compContainer = [[LOTCompositionContainer alloc] initWithModel:nil inLayerGroup:nil withLayerGroup:_sceneModel.layerGroup withAssestGroup:_sceneModel.assetGroup];
        [self startLoaderLottieBuffer];
    }
}

- (void)lottieLoadWithUrl:(NSString *)url {
    NSURL *imageUrl = [NSURL URLWithString:url];
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfURL:imageUrl];
    NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (JSONObject && !error) {
        _sceneModel = [LOTComposition animationFromJSON:JSONObject];
        if (_sceneModel) {
            self.lottieViewSize = _sceneModel.compBounds.size;
            _compContainer = [[LOTCompositionContainer alloc] initWithModel:nil inLayerGroup:nil withLayerGroup:_sceneModel.layerGroup withAssestGroup:_sceneModel.assetGroup];
            [self startLoaderLottieBuffer];
        }
    }
}

- (void)lottieReload {
    if (self.compContainer == nil) {
        if (self.path.length > 0) {
            [self lottieLoadWithLocalPath:self.path];
            return;
        }
        if (self.url.length > 0) {
            [self lottieLoadWithUrl:self.url];
        }
    }
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

- (void)startLoaderLottieBuffer {
    CGFloat duration = [self getDuration];
    CGFloat frameRate = KLottieFrameRate;
    NSUInteger count = frameRate * duration;//最好限制数量，比如100以内。曾看到内存增长到1G，
    for (int i = 0; i<count; i++) {
        CGFloat progress = i/(CGFloat)count;        
        NSNumber *currentFrame = [self frameForProgress:progress sceneModel:_sceneModel];
        [self setLayerToFrame:currentFrame];
        CVPixelBufferRef buffer = [ImageConvertor pixelBufferLeftLandscapeFromLayer:_compContainer frameSize:self.lottieViewSize];
        
        TextureModel *model = [[TextureModel alloc]init];
        model.buffer = buffer;
        [self.buffers addObject:model];
        CFRelease(buffer);//这个是因为TextureModel申明时用了retain。可以修改。
    }
}

- (BOOL)isGenerateFinish {
    CGFloat duration = [self getDuration];
    CGFloat frameRate = KLottieFrameRate;
    NSUInteger count = frameRate * duration;//最好限制数量，100以内。曾看到内存增长到1G，
    return count == self.buffers.count;
}

#pragma mark - < getter >
- (NSMutableArray<TextureModel *> *)buffers {
    if (_buffers == nil) {
        _buffers = [NSMutableArray arrayWithCapacity:0];
    }
    return _buffers;
}

@end
