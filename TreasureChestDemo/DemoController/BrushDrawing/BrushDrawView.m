//
//  BrushDrawView.m
//  TreasureChest
//
//  Created by jf on 2020/7/22.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "BrushDrawView.h"

@interface BrushDrawView () {
    CGContextRef _drawContext;
}

@property(nonatomic, assign)CGPoint startPoint;
@property(nonatomic, assign)CGPoint endPoint;
@property(nonatomic, strong)UIImage *drawingImage;
@property(nonatomic, strong)UIImageView *topImageView;//放在最上层，透明，加了maskLayer.

@property(nonatomic, strong)CAShapeLayer *maskLayer;
@property(nonatomic, strong)UIBezierPath *path;

@end

@implementation BrushDrawView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self == [super initWithFrame:frame]){
        self.userInteractionEnabled = true;
        self.backgroundColor = [UIColor lightGrayColor];
        [self createContext];
        [self initView];
    }
    return self;
}

- (void)initView {
    self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bgPic1"].CGImage);
    
    //maskLayer加到topImageView的masK。maskLayer有颜色部分将显示被masK遮挡的底层原本颜色。
    self.maskLayer = [CAShapeLayer layer];
    self.maskLayer.frame = self.bounds;
//    [self.layer setMask:self.maskLayer];
    
    //透明，不设置背景色
    self.topImageView = [[UIImageView alloc]init];
    self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.topImageView.frame = self.bounds;
    self.topImageView.image = [UIImage imageNamed:@"bgPic"];
    [self addSubview:self.topImageView];
    [self.topImageView.layer setMask:self.maskLayer];
}

- (void)createContext {
    /** https://www.jianshu.com/p/e8c9910021cb
     data：指向要渲染绘制的内存地址。这个内存块大小至少为（bytesPerRow*height）个字节。使用时可传NULL，系统会自动分配内存。
     width：所需位图(bitmap)的宽度，单位为像素。
     height：所需位图(bitmap)的高度，单位为像素。
     bitsPerComponent：内存中像素分量的位数。如，对于32位像素格式和RGB颜色空间时，该值赢设为8。有关支持的像素格式，参阅 Graphics Contexts 中的 Quartz 2D Programming Guide.
     bytesPerRow：位图每行内存所占的字节数，一个像素一个byte。若前面参数data传的是NULL，则该参数传入0来自动计算。
     space：bitmap上下文用的颜色空间。注意，位图上下文不支持颜色空间索引。。
     bitmapInfo：用于指定位图是否包含Alpha通道、Alpha通道在像素中的相对位置、像素分量是整型还是浮点型等信息的常量。想要了解如何指定颜色空间，像素字节数，像素分量字节数，参考 Graphics Contexts
     （https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html#//apple_ref/doc/uid/TP30001066-CH203）
     */
//    CGBitmapContextCreateImage(ctx);//从ctx获取图片。
    //CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), imageRef);//将图片写入到context中；
    
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
    
    //坐标系转换
    CGContextTranslateCTM(_drawContext, 0, self.size.height);
    CGContextScaleCTM(_drawContext, 1.0, -1.0);
}



#pragma mark - < touch >
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.startPoint = [[touches anyObject] locationInView:self];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    
}

//这个试图在一条线段有多个颜色
/**
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
    self.endPoint = [[touches anyObject] locationInView:self];
    UIGraphicsPushContext(_drawContext);
    {
        for (int i = 0; i<3; i++) {//可以一次添加多个，绘制一次。
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(_startPoint.x+i*12, _startPoint.y+i*12)];
            [path addLineToPoint:CGPointMake(_endPoint.x+i*12, _endPoint.y+i*12)];
            [path setLineWidth:2];
//            [[UIColor redColor]setStroke];
            [[UIColor colorWithRed:(255-i*140)/255.0 green:0 blue:0 alpha:1] setStroke];
            [path stroke];
            
            [path addLineToPoint:CGPointMake(_endPoint.x+i*12 + 33, _endPoint.y+i*12 + 13)];
            [[UIColor colorWithRed:0 green:(255-i*140)/255.0 blue:0 alpha:1] setStroke];
            [path stroke];
            
        }
        CGImageRef imageRef = CGBitmapContextCreateImage(_drawContext);
        self.drawingImage = [UIImage imageWithCGImage:imageRef];
//        self.maskLayer.contents = (__bridge id _Nullable)(imageRef);
        CGImageRelease(imageRef);//释放
    }
    UIGraphicsPopContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = self.drawingImage;
    });
    
//    self.image = (__bridge UIImage * _Nullable)(CGBitmapContextCreateImage(_drawContext));
    
}

 */

// /** 用这个
 - (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     NSLog(@"touchesEnded");
     self.endPoint = [[touches anyObject] locationInView:self];
     UIGraphicsPushContext(_drawContext);
     {
         for (int i = 0; i<1; i++) {//可以一次添加多个，绘制一次。
             CGContextMoveToPoint(_drawContext, _startPoint.x+i*2, _startPoint.y+i*2);//设置Path的起点
             CGContextAddLineToPoint(_drawContext, _endPoint.x+i*2, _endPoint.y+i*2);
             
 //            CGContextMoveToPoint(_drawContext, _endPoint.x+i*2, _endPoint.y+i*2);
             CGContextAddLineToPoint(_drawContext, _endPoint.x+10, _endPoint.y+18);
             CGContextSetStrokeColorWithColor(_drawContext, [UIColor redColor].CGColor);
 //            CGContextSetBlendMode(_drawContext, kCGBlendModeClear);
             CGContextStrokePath(_drawContext);//一定要画了，不然这个函数CGContextSetStrokeColorWithColor，会把所有线条变成一个颜色
         }
         CGImageRef imageRef = CGBitmapContextCreateImage(_drawContext);
 //        self.drawingImage = [UIImage imageWithCGImage:imageRef];
         self.maskLayer.contents = (__bridge id _Nullable)(imageRef);
         CGImageRelease(imageRef);//释放
     }
     UIGraphicsPopContext();
     
     dispatch_async(dispatch_get_main_queue(), ^{
         self.image = self.drawingImage;
     });
     
 //    self.image = (__bridge UIImage * _Nullable)(CGBitmapContextCreateImage(_drawContext));
     
 }
// */


@end
