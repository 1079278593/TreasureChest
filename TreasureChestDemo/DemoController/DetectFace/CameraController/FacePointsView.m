//
//  FacePointsView.m
//  TreasureChest
//
//  Created by jf on 2020/10/14.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "FacePointsView.h"

@interface FacePointsView ()

@property(nonatomic, strong)UIView *dotView;
@property(nonatomic, assign)CGRect videoPreviewRect;

@end

@implementation FacePointsView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
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

    // Landmarks是相对的，并且在‘face bounds’内是归一化的
    CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(faceBounds.origin.x, faceBounds.origin.y);
    affineTransform = CGAffineTransformScale(affineTransform, faceBounds.size.width, faceBounds.size.height);
    
    // 在画路径时，把眉毛和线当作开放区域。
    NSMutableArray <VNFaceLandmarkRegion2D *> *openLandmarkRegions = [NSMutableArray arrayWithCapacity:0];
    [openLandmarkRegions addObject:landmarks.faceContour];  //脸部下部分轮廓
    [openLandmarkRegions addObject:landmarks.leftEyebrow];  //左眉毛
    [openLandmarkRegions addObject:landmarks.rightEyebrow]; //右眉毛
    [openLandmarkRegions addObject:landmarks.leftEye];      //左眼
    [openLandmarkRegions addObject:landmarks.rightEye];     //右眼
    [openLandmarkRegions addObject:landmarks.nose];         //鼻子
    [openLandmarkRegions addObject:landmarks.noseCrest];    //鼻尖
    [openLandmarkRegions addObject:landmarks.outerLips];    //外唇
    [openLandmarkRegions addObject:landmarks.innerLips];    //内唇
//    [openLandmarkRegions addObject:landmarks.medianLine];   //中间线，不要了
    for (VNFaceLandmarkRegion2D *openLandmarkRegion in openLandmarkRegions) {
        [self addPoints:openLandmarkRegion toPath:faceLandmarksPath applyingAffineTransform:affineTransform closingWhenComplete:false];
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

#pragma mark - < init view >
- (void)initView {
    _dotView = [[UIView alloc]init];
    _dotView.layer.cornerRadius = 2;
    _dotView.backgroundColor = [UIColor redColor];
    _dotView.frame = CGRectMake(10, 110, 4, 4);
    [self addSubview:_dotView];
}

@end
