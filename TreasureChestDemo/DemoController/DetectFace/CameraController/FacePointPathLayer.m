//
//  FacePointPathLayer.m
//  TreasureChest
//
//  Created by jf on 2020/10/14.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FacePointPathLayer.h"

@interface FacePointPathLayer ()

@property(nonatomic, assign)CGSize captureDeviceResolution;
@property(nonatomic, assign)CGRect videoPreviewRect;

@property(nonatomic, strong)CAShapeLayer *detectedFaceRectangleShapeLayer;
@property(nonatomic, strong)CAShapeLayer *detectedFaceLandmarksShapeLayer;

@end

@implementation FacePointPathLayer

- (instancetype)initWithDeviceResolution:(CGSize)captureDeviceResolution {
    if(self == [super init]){
        self.name = @"DetectionOverlay";
        self.masksToBounds = true;
        
        self.captureDeviceResolution = captureDeviceResolution;
        [self initLayer];
    }
    return self;
}

#pragma mark - < public >
- (void)refreshWithLandmarkResults:(NSArray <VNFaceObservation *> *)faceObservations videoPreviewRect:(CGRect)videoPreviewRect {
    self.videoPreviewRect = videoPreviewRect;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGMutablePathRef faceRectanglePath = CGPathCreateMutable();
    CGMutablePathRef faceLandmarksPath = CGPathCreateMutable();
    for (VNFaceObservation * faceObservation in faceObservations) {
        [self addIndicators:faceRectanglePath faceLandmarksPath:faceLandmarksPath faceObservation:faceObservation];
    }
    
    _detectedFaceRectangleShapeLayer.path = faceRectanglePath;
    _detectedFaceLandmarksShapeLayer.path = faceLandmarksPath;
    
    [self updateLayerGeometry];
    [CATransaction commit];
}

#pragma mark - < private >
- (void)addIndicators:(CGMutablePathRef)faceRectanglePath faceLandmarksPath:(CGMutablePathRef)faceLandmarksPath faceObservation:(VNFaceObservation *)faceObservation {
    CGSize displaySize = self.bounds.size;//self.bounds.size为摄像头的分辨率
    CGRect faceBounds = VNImageRectForNormalizedRect(faceObservation.boundingBox, (size_t)displaySize.width, (size_t)displaySize.height);
    CGPathAddRect(faceRectanglePath, nil, faceBounds);
    
    VNFaceLandmarks2D *landmarks = faceObservation.landmarks;
    if (landmarks == nil) {
        return;
    }
    
    // Landmarks地标是相对的，并且在‘face bounds’内是归一化的
    CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(faceBounds.origin.x, faceBounds.origin.y);
    affineTransform = CGAffineTransformScale(affineTransform, faceBounds.size.width, faceBounds.size.height);
    
    // 在画路径时，把眉毛和线当作开放区域。
    NSMutableArray <VNFaceLandmarkRegion2D *> *openLandmarkRegions = [NSMutableArray arrayWithCapacity:0];
    [openLandmarkRegions addObject:landmarks.leftEyebrow];
    [openLandmarkRegions addObject:landmarks.rightEyebrow];
    [openLandmarkRegions addObject:landmarks.faceContour];
    [openLandmarkRegions addObject:landmarks.noseCrest];
    [openLandmarkRegions addObject:landmarks.medianLine];
    
    for (VNFaceLandmarkRegion2D *openLandmarkRegion in openLandmarkRegions) {
        [self addPoints:openLandmarkRegion toPath:faceLandmarksPath applyingAffineTransform:affineTransform closingWhenComplete:false];
    }
    
    // 画眼睛，嘴唇和鼻子作为封闭的区域。
    NSMutableArray <VNFaceLandmarkRegion2D *> *closedLandmarkRegions = [NSMutableArray arrayWithCapacity:0];
    [closedLandmarkRegions addObject:landmarks.leftEye];
    [closedLandmarkRegions addObject:landmarks.rightEye];
    [closedLandmarkRegions addObject:landmarks.outerLips];
    [closedLandmarkRegions addObject:landmarks.innerLips];
    [closedLandmarkRegions addObject:landmarks.nose];
    
    for (VNFaceLandmarkRegion2D *closedLandmarkRegion in closedLandmarkRegions) {
        [self addPoints:closedLandmarkRegion toPath:faceLandmarksPath applyingAffineTransform:affineTransform closingWhenComplete:true];
    }
}

- (void)addPoints:(VNFaceLandmarkRegion2D *)landmarkRegion toPath:(CGMutablePathRef)path applyingAffineTransform:(CGAffineTransform)affineTransform closingWhenComplete:(BOOL)closePath {
    NSUInteger pointCount = landmarkRegion.pointCount;
    if (pointCount > 1) {
        CGPoint firstPoint = landmarkRegion.normalizedPoints[0];
        CGPathMoveToPoint(path, &affineTransform, firstPoint.x, firstPoint.y);
        CGPathAddLines(path, &affineTransform, landmarkRegion.normalizedPoints, pointCount);
        if (closePath) {
            CGPathAddLineToPoint(path, &affineTransform, firstPoint.x, firstPoint.y);
            CGPathCloseSubpath(path);
        }
    }
}

- (void)updateLayerGeometry {
    CGRect videoPreviewRect = self.videoPreviewRect;
    
    CGFloat rotation ,scaleX ,scaleY;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
        {
            rotation = 180;
            scaleX = videoPreviewRect.size.width / self.bounds.size.width;
            scaleY = videoPreviewRect.size.height / self.bounds.size.height;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            rotation = 90;
            scaleX = videoPreviewRect.size.height / self.bounds.size.width;
            scaleY = scaleX;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            rotation = -90;
            scaleX = videoPreviewRect.size.height / self.bounds.size.width;
            scaleY = scaleX;
        }
            break;
            
        default:
            rotation = 0;
            scaleX = videoPreviewRect.size.width / self.bounds.size.width;
            scaleY = videoPreviewRect.size.height / self.bounds.size.height;
            break;
    }
    
    CGAffineTransform affineTransform = CGAffineTransformMakeRotation([self radiansForDegrees:rotation]);
    affineTransform = CGAffineTransformScale(affineTransform, scaleX, -scaleY);
    [self setAffineTransform:affineTransform];
    self.position = CGPointMake(KScreenWidth/2.0, KScreenHeight/2.0);
}

- (CGFloat)radiansForDegrees:(CGFloat)degrees {
    return degrees * M_PI / 180.0;
}

#pragma mark - < init view >
- (void)initLayer {
    CGRect captureDeviceBounds = CGRectMake(0, 0, self.captureDeviceResolution.width, self.captureDeviceResolution.height);
    CGPoint captureDeviceBoundsCenterPoint = CGPointMake(captureDeviceBounds.size.width/2.0, captureDeviceBounds.size.height/2.0);
    CGPoint normalizedCenterPoint = CGPointMake(0.5, 0.5);
    
    self.anchorPoint = normalizedCenterPoint;
    
    CAShapeLayer *faceRectangleShapeLayer = [[CAShapeLayer alloc]init];
    faceRectangleShapeLayer.name = @"RectangleOutlineLayer";
    faceRectangleShapeLayer.bounds = captureDeviceBounds;
    faceRectangleShapeLayer.anchorPoint = normalizedCenterPoint;
    faceRectangleShapeLayer.position = captureDeviceBoundsCenterPoint;
    faceRectangleShapeLayer.fillColor = nil;
    faceRectangleShapeLayer.strokeColor  = [[UIColor greenColor]colorWithAlphaComponent:0.7].CGColor;
    faceRectangleShapeLayer.lineWidth = 5;
    faceRectangleShapeLayer.shadowOpacity = 0.7;
    faceRectangleShapeLayer.shadowRadius = 5;
    
    CAShapeLayer *faceLandmarksShapeLayer = [[CAShapeLayer alloc]init];
    faceLandmarksShapeLayer.name = @"FaceLandmarksLayer";
    faceLandmarksShapeLayer.bounds = captureDeviceBounds;
    faceLandmarksShapeLayer.anchorPoint = normalizedCenterPoint;
    faceLandmarksShapeLayer.position = captureDeviceBoundsCenterPoint;
    faceLandmarksShapeLayer.fillColor = nil;
    faceLandmarksShapeLayer.strokeColor  = [[UIColor yellowColor]colorWithAlphaComponent:0.7].CGColor;
    faceLandmarksShapeLayer.lineWidth = 3;
    faceLandmarksShapeLayer.shadowOpacity = 0.7;
    faceLandmarksShapeLayer.shadowRadius = 5;
    
    [self addSublayer:faceRectangleShapeLayer];
    [faceRectangleShapeLayer addSublayer:faceLandmarksShapeLayer];
    
    self.detectedFaceRectangleShapeLayer = faceRectangleShapeLayer;
    self.detectedFaceLandmarksShapeLayer = faceLandmarksShapeLayer;
    
    [self updateLayerGeometry];
}

@end
