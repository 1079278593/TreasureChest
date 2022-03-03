//
//  CoordinatesView.m
//  TreasureChest
//
//  Created by imvt on 2022/1/14.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "CoordinatesView.h"

@interface CoordinatesView () {
    CGContextRef _drawContext;
}

@property(nonatomic, assign)CGFloat xValue;
@property(nonatomic, assign)CGFloat yValue;

@property(nonatomic, assign)CGFloat xStep;
@property(nonatomic, assign)CGFloat yStep;

@property(nonatomic, assign)CGFloat xAccuracy;
@property(nonatomic, assign)CGFloat yAccuracy;

@property(nonatomic, assign)CGFloat padding;
@property(nonatomic, assign)CGSize efficientSize;       //!< 刻度尺有效的尺寸

@property(nonatomic, strong)UIView *xyAxisView;

@end

@implementation CoordinatesView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.efficientSize = CGSizeMake(self.width, self.height);
        self.padding = 10;//四周个增加10单位的空白
        self.frame = CGRectMake(self.x - self.padding, self.y, self.width+self.padding*2, self.height+self.padding*2);
        self.xValue = 1;
        self.yValue = 1;
        self.xStep = 0.1;
        self.yStep = 0.1;
        self.xAccuracy = 0.01;
        self.yAccuracy = 0.01;
        [self setupSubviews];
        [self createContextWithSize:self.size];
    }
    return self;
}

- (void)dealloc {
    CGContextRelease(_drawContext);
}

#pragma mark - < public >
///xValue~x轴最大值(默认1)，step~有值刻度的距离(默认0.1)，accuracy~最小间隔(最小刻度，默认0.01)。
- (void)xAxisValue:(CGFloat)xValue step:(CGFloat)step accuracy:(CGFloat)accuracy {
    self.xValue = xValue;
    self.xStep = step;
    self.xAccuracy = accuracy;
}

///yValue~y轴最大值(默认1)，step~有值刻度的距离(默认0.1)，accuracy~最小间隔(最小刻度，默认0.01)。
- (void)yAxisValue:(CGFloat)yValue step:(CGFloat)step accuracy:(CGFloat)accuracy {
    self.yValue = yValue;
    self.yStep = step;
    self.yAccuracy = accuracy;
}

//- (void)startDraw {
//    CGContextRef context = _drawContext;
//
//    CGMutablePathRef pathRef = [self drawVerticalPointsWithContext:context];
//    CGMutablePathRef horizontalPathRef = [self drawHorizontalPointsWithContext:context];
//    CGPathAddPath(pathRef, &CGAffineTransformIdentity, horizontalPathRef);
//
//    UIGraphicsPushContext(context);
//    {
//        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
//        CGContextSetLineWidth(context, 1);
//
//        UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
//        bezierPath.CGPath = pathRef;
//        [bezierPath stroke];
//
//        CGImageRef imageRef = CGBitmapContextCreateImage(context);
//        self.xyAxisView.layer.contents = (__bridge id _Nullable)(imageRef);
//    }
//    UIGraphicsPopContext();
//}

#pragma mark - < draw >
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGMutablePathRef pathRef = [self drawVerticalPointsWithContext:context];
    CGMutablePathRef horizontalPathRef = [self drawHorizontalPointsWithContext:context];
    CGPathAddPath(pathRef, &CGAffineTransformIdentity, horizontalPathRef);

    UIGraphicsPushContext(context);
    {
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 1);

        UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
        bezierPath.CGPath = pathRef;
        [bezierPath stroke];
    }
    UIGraphicsPopContext();
}

#pragma mark - < private >
- (CGMutablePathRef)drawVerticalPointsWithContext:(CGContextRef)context {
    CGFloat yValue = self.yValue;
    CGFloat yStep = self.yStep;
    CGFloat yAccuracy = self.yAccuracy;
    CGFloat height = self.efficientSize.height;
    
    int bigCount = yValue / yStep;
    int microCount = yStep / yAccuracy;
    int totalCount = bigCount * microCount;
    
    CGFloat stepHeight = height / totalCount;//最小刻度间距。
    CGFloat offset = self.padding;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();

    //1.先绘制直线
    CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, offset, offset);
    CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, offset, height+offset);
    
    //2.再绘制刻度
    for (int i = 0; i<totalCount+1; i++) {
        CGFloat lineY = i*stepHeight+offset;
        CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, offset, lineY);
        CGFloat lienWidth = 3;
        if (i % microCount == 0) {
            //长度更长，且绘制数字
            lienWidth = 6;
        }
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, offset+lienWidth, lineY);
    }
    return pathRef;
}

- (CGMutablePathRef)drawHorizontalPointsWithContext:(CGContextRef)context {
    CGFloat xValue = self.xValue;
    CGFloat xStep = self.xStep;
    CGFloat xAccuracy = self.xAccuracy;
    CGFloat width = self.efficientSize.width;
    
    int bigCount = xValue / xStep;
    int microCount = xStep / xAccuracy;
    int totalCount = bigCount * microCount;
    
    CGFloat stepWidth = width / totalCount;//最小刻度间距。
    
    CGFloat offsetY = self.height - self.padding;
    CGFloat offsetX = self.padding;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    //1.先绘制直线
    CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, offsetX, offsetY);
    CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, self.width - offsetX, offsetY);
    
    //2.再绘制刻度
    for (int i = 0; i<totalCount+1; i++) {
        CGFloat lineX = offsetX + i*stepWidth;
        CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, lineX, offsetY);
        CGFloat lienHeight = 3;
        if (i % microCount == 0) {
            //长度更长，且绘制数字
            lienHeight = 6;
        }
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, lineX, offsetY-lienHeight);
    }
    
    return pathRef;
}

#pragma mark - < init view >
- (void)setupSubviews {
//    self.xyAxisView = [[UIView alloc]init];
//    self.xyAxisView.frame = self.bounds;
//    [self addSubview:self.xyAxisView];
}

- (void)createContextWithSize:(CGSize)size {
    int scale = 1;
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = size.width * 4;      //RGBA
    
    //用完要自己释放：CGContextRelease(context);CGColorSpaceRelease(colorSpace);
    _drawContext = CGBitmapContextCreate(calloc(sizeof(unsigned char), bytesPerRow * size.height),
                                          size.width * scale,
                                          size.height * scale,
                                          bitsPerComponent,
                                          bytesPerRow,
                                          CGColorSpaceCreateDeviceRGB(),
                                          kCGImageAlphaPremultipliedLast);
    //坐标系转换
    CGContextTranslateCTM(_drawContext, 0, size.height);
    CGContextScaleCTM(_drawContext, 1.0, -1.0);
}

@end
