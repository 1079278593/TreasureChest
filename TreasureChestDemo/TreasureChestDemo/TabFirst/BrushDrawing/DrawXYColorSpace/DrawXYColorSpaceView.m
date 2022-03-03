//
//  DrawXYColorSpaceView.m
//  TreasureChest
//
//  Created by imvt on 2022/1/12.
//  Copyright © 2022 xiao ming. All rights reserved.
//

#import "DrawXYColorSpaceView.h"
#import "CIEColorSpaceModel.h"
#import "CoordinatesView.h"

@interface DrawXYColorSpaceView () {
    CGContextRef _drawContext;
}

@property(nonatomic, strong)CIEColorSpaceModel *colorSpaceModel;
@property(nonatomic, strong)UIBezierPath *xyAreaBezierPath;
@property(nonatomic, strong)UIBezierPath *cctLocusBezierPath;

@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIImageView *rec709MaskImageView;
@property(nonatomic, strong)UIImageView *rec2020MaskImageView;
@property(nonatomic, strong)UIView *plistPathView;
@property(nonatomic, strong)UIView *stellarPathView;

@property(nonatomic, strong)CoordinatesView *coordinatesView;

@property(nonatomic, strong)UIButton *hidePlistBtn;     //!< 隐藏我扒下来数据 绘制的线
@property(nonatomic, strong)UIButton *hideStellarBtn;   //!< 隐藏stellar的线

@end

@implementation DrawXYColorSpaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
        [self createContext];
        [self drawPlistPoints];
        [self drawPlistPLKPoints];
//        [self drawStellarPoints];
    }
    return self;
}

#pragma mark - < event >
- (void)hidePlistBtnEvent:(UIButton *)button {
    button.selected = !button.selected;
    self.plistPathView.hidden = button.selected;
}

- (void)hideStellarBtnEvent:(UIButton *)button {
    button.selected = !button.selected;
    self.stellarPathView.hidden = button.selected;
}

#pragma mark - < draw >
- (void)drawPlistPoints {
    NSArray <CIEAreaPointModel *> *points = [self loadPlistPoints];
    
    CGMutablePathRef pathRef = [self componentPathWithPoints:points isClose:YES size:self.size];
    self.xyAreaBezierPath = [[UIBezierPath alloc] init];
    self.xyAreaBezierPath.CGPath = pathRef;
    
    UIGraphicsPushContext(_drawContext);
    {//共用_drawContext，会导致之后绘制的path也再次绘制本次添加的path。
        CGContextSetStrokeColorWithColor(_drawContext, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(_drawContext, 1);
        [self.xyAreaBezierPath stroke];
        CGImageRef imageRef = CGBitmapContextCreateImage(_drawContext);
        self.plistPathView.layer.contents = (__bridge id _Nullable)(imageRef);
    }
    UIGraphicsPopContext();
}

- (void)drawPlistPLKPoints {
//    return;
//    NSArray <PLKRadiationPathModel *> *points = [self loadPlistPLKPoints];
    NSArray <PLKRadiationPathModel *> *points = [self loadStellarPLKJson];//这个更准确
    
    CGMutablePathRef pathRef = [self componentPathWithPoints:points isClose:NO size:self.size];
    self.cctLocusBezierPath = [[UIBezierPath alloc] init];
    self.cctLocusBezierPath.CGPath = pathRef;
    
    UIGraphicsPushContext(_drawContext);
    {//共用_drawContext，会导致之前绘制的path也再次绘制。
        CGContextSetStrokeColorWithColor(_drawContext, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(_drawContext, 1);
        [self.cctLocusBezierPath stroke];
        
        CGImageRef imageRef = CGBitmapContextCreateImage(_drawContext);
        self.stellarPathView.layer.contents = (__bridge id _Nullable)(imageRef);
    }
    UIGraphicsPopContext();
}

//对比发现，轨迹是一样的。这里用CGContext绘制
- (void)drawStellarPoints {
    NSArray <CIEAreaPointModel *> *points = [self loadStellarJson];
    
    UIGraphicsPushContext(_drawContext);
    {//共用_drawContext，会导致之前绘制的path也再次绘制。
        CGContextSetStrokeColorWithColor(_drawContext, [UIColor redColor].CGColor);
        CGContextSetLineWidth(_drawContext, 1);
        
        for (int i = 1; i<points.count; i++) {
            CGPoint startPoint = CGPointMake(points[i-1].x.floatValue * self.width, points[i-1].y.floatValue * self.height);
            CGContextMoveToPoint(_drawContext, startPoint.x, startPoint.y);
            CGPoint point = CGPointMake(points[i].x.floatValue * self.width, points[i].y.floatValue * self.height);
            CGContextAddLineToPoint(_drawContext, point.x, point.y);
            
            CGContextStrokePath(_drawContext);
        }
        CGImageRef imageRef = CGBitmapContextCreateImage(_drawContext);
        self.stellarPathView.layer.contents = (__bridge id _Nullable)(imageRef);
    }
    UIGraphicsPopContext();
    
}

#pragma mark - < private >
///plist数据绘制：xy范围
- (NSArray *)loadPlistPoints {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CIEColorSpace" ofType:@"plist"];
    self.colorSpaceModel = [CIEColorSpaceModel mj_objectWithFile:path];
    NSMutableArray <CIEAreaPointModel *> *points = self.colorSpaceModel.areaPoints;
    return points;
}

///plist数据绘制：黑体辐射轨迹
- (NSArray *)loadPlistPLKPoints {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CIEColorSpace" ofType:@"plist"];
    self.colorSpaceModel = [CIEColorSpaceModel mj_objectWithFile:path];
    NSMutableArray <PLKRadiationPathModel *> *points = self.colorSpaceModel.radiationTrajectory;
    [points removeObjectAtIndex:0];
    [points removeObjectAtIndex:0];
    [points removeObjectAtIndex:0];//从cct等于1600开始，1000的数据保留。
    return points;
}

///加载stellar的点数据：用于对比
- (NSArray *)loadStellarJson {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"stellar_xy_gamut_shape" ofType:@"json"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *arr = [CIEAreaPointModel mj_objectArrayWithKeyValuesArray:dict];
    return arr;
}

- (NSArray *)loadStellarPLKJson {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"stellar_xy_cct_curve" ofType:@"json"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *arr = [PLKRadiationPathModel mj_objectArrayWithKeyValuesArray:dict];
    return arr;
}

- (CGMutablePathRef)componentPathWithPoints:(NSArray <CIEPointModel*> *)points isClose:(BOOL)isClose size:(CGSize)size {
    CGMutablePathRef pathRef = CGPathCreateMutable();
    for (int i = 1; i<points.count; i++) {
        CGPoint startPoint = CGPointMake(points[i-1].x.floatValue * size.width, points[i-1].y.floatValue * size.height);
        CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, startPoint.x, startPoint.y);
        CGPoint point = CGPointMake(points[i].x.floatValue * size.width, points[i].y.floatValue * size.height);
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, point.x, point.y);
    }
    
    if (isClose) {//闭合
        CGPoint startPoint = CGPointMake(points.lastObject.x.floatValue * size.width, points.lastObject.y.floatValue * size.height);
        CGPathMoveToPoint(pathRef, &CGAffineTransformIdentity, startPoint.x, startPoint.y);
        CGPoint point = CGPointMake(points.firstObject.x.floatValue * size.width, points.firstObject.y.floatValue * size.height);
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, point.x, point.y);
    }
    return pathRef;
}

#pragma mark - < init view >
- (void)setupSubviews {
    UIImage *bgImage = [UIImage imageNamed:@"xyColorSpec"];
    CGFloat width = self.width * 0.8;
    CGFloat height = self.height * 0.9;
    self.bgImageView = [[UIImageView alloc]init];
    self.bgImageView.frame = CGRectMake(0, 0, width, height);
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;//这里要拉伸，size(self.width * 0.8, self.height * 0.9)
    self.bgImageView.image = bgImage;
    [self addSubview:self.bgImageView];
//    self.bgImageView.layer.borderWidth = 1;
    
    
    
    
    self.plistPathView = [[UIView alloc]init];
    self.plistPathView.frame = self.bounds;
    [self addSubview:self.plistPathView];
    
    self.stellarPathView = [[UIView alloc]init];
    self.stellarPathView.frame = self.bounds;
    [self addSubview:self.stellarPathView];
    
    
    
    _hidePlistBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hidePlistBtn setTitle:@"plist" forState:UIControlStateNormal];
    [_hidePlistBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_hidePlistBtn addTarget:self action:@selector(hidePlistBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hidePlistBtn];
    [_hidePlistBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.width.height.equalTo(@50);
    }];
    
    _hideStellarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hideStellarBtn setTitle:@"stellar" forState:UIControlStateNormal];
    [_hideStellarBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_hideStellarBtn addTarget:self action:@selector(hideStellarBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hideStellarBtn];
    [_hideStellarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.width.height.equalTo(@50);
    }];
    
    self.bgImageView.bottom = self.plistPathView.bottom;
    
//    self.rec709MaskImageView.hidden = NO;
//    self.rec2020MaskImageView.hidden = NO;
    
    self.coordinatesView = [[CoordinatesView alloc]initWithFrame:CGRectMake(10, self.plistPathView.bottom - 150, 300, 300)];
    [self addSubview:self.coordinatesView];
    [self.coordinatesView xAxisValue:0.8 step:0.1 accuracy:0.01];
    [self.coordinatesView yAxisValue:0.9 step:0.1 accuracy:0.01];
}

- (void)createContext {
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = self.size.width * 4;      //RGBA
    
    //用完要自己释放：CGContextRelease(context);CGColorSpaceRelease(colorSpace);
    _drawContext = CGBitmapContextCreate(calloc(sizeof(unsigned char), bytesPerRow * self.size.height),
                                          self.size.width,
                                          self.size.height,
                                          bitsPerComponent,
                                          bytesPerRow,
                                          CGColorSpaceCreateDeviceRGB(),
                                          kCGImageAlphaPremultipliedLast);
}

- (UIImageView *)rec709MaskImageView {
    if (_rec709MaskImageView == nil) {
        _rec709MaskImageView = [[UIImageView alloc]init];
        _rec709MaskImageView.frame = self.bgImageView.frame;
        _rec709MaskImageView.contentMode = UIViewContentModeScaleToFill;
        _rec709MaskImageView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"xyrec709"].CGImage);
        [self addSubview:_rec709MaskImageView];
        _rec709MaskImageView.hidden = YES;
    }
    return _rec709MaskImageView;
}

- (UIImageView *)rec2020MaskImageView {
    if (_rec2020MaskImageView == nil) {
        _rec2020MaskImageView = [[UIImageView alloc]init];
        _rec2020MaskImageView.frame = self.bgImageView.frame;
        _rec2020MaskImageView.contentMode = UIViewContentModeScaleToFill;
        _rec2020MaskImageView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"xyrec2020"].CGImage);
        [self addSubview:_rec2020MaskImageView];
        _rec2020MaskImageView.hidden = YES;
    }
    return _rec2020MaskImageView;
}

@end
