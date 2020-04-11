//
//  DrawingBoardView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/10.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "DrawingBoardView.h"
@interface DrawingBoardView (){
    CGPoint location,previousLocation;
    CGPoint previousMidPoint;
    CGFloat brushWidth;
    NSString *brushTextImageName;
    UIColor *lineColor;
    
    BOOL firstTouch;
}

@property (nonatomic, strong) UIBezierPath *renderPath;
@property (nonatomic, strong) UIBezierPath *currentPath;
@property (nonatomic, assign) CGPoint ctlPoint;
@property (nonatomic, assign) CGFloat prePathLength;

@end

@implementation DrawingBoardView

- (instancetype)init {
    if(self == [super init]){
        [self initView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{

    [[UIColor redColor] set];

    UIBezierPath* path = self.renderPath;

    path.lineWidth     = 5.f;
    path.lineCapStyle  = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;

    [path stroke];
    
    self.renderPath = nil;
}

#pragma mark - touchesEvent
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [[event touchesForView:self] anyObject];
    previousLocation = [touch locationInView:self];
    
    self.currentPath = [UIBezierPath bezierPath];
    [self.currentPath moveToPoint:previousLocation];
    self.renderPath = [UIBezierPath bezierPathWithCGPath:self.currentPath.CGPath];
    firstTouch = YES;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    location = [touch locationInView:self];
    
    if (self.renderPath == nil) {
        self.renderPath = [UIBezierPath bezierPath];
        [self.renderPath moveToPoint:self.currentPath.currentPoint];
    }
    if (CGPointEqualToPoint(self.ctlPoint, CGPointZero)) {
        self.ctlPoint = location;
        CGPoint midPoint = CGPointMake((self.currentPath.currentPoint.x + location.x) * 0.5, (self.currentPath.currentPoint.y + location.y) * 0.5);
        [self.currentPath addLineToPoint:midPoint];
        [self.renderPath addLineToPoint:midPoint];
    } else {
        CGPoint midPoint = CGPointMake((location.x + self.ctlPoint.x) * 0.5, (location.y + self.ctlPoint.y) * 0.5);
        [self.currentPath addQuadCurveToPoint:midPoint controlPoint:self.ctlPoint];
        self.ctlPoint = location;
        [self.renderPath addQuadCurveToPoint:midPoint controlPoint:self.ctlPoint];
        firstTouch = NO;
    }
    
    [self setNeedsDisplay];//强制更新
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
    self.ctlPoint = CGPointZero;
}

#pragma mark - < init >
- (void)initView {
    
}


@end
