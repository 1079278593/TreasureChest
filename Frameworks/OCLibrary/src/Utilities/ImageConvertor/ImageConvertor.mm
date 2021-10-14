//
//  ImageConvertor.m
//  Poppy_Dev01
//
//  Created by jf on 2020/12/23.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "ImageConvertor.h"

@implementation ImageConvertor

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

//degree
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#pragma mark - < get pixel buffer >
+ (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image {
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage)), image.CGImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

//给’遮罩‘用
+ (CVPixelBufferRef)pixelBufferFromImage1:(UIImage *)image {
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage));
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    /**
     创建一个 BGRA 格式的PixelBuffer，注意kCVPixelBufferOpenGLESCompatibilityKey和kCVPixelBufferIOSurfacePropertiesKey这两个属性，这是为了实现和openGL兼容，另外有些地方要求CVPixelBufferRef必须是 IO Surface。
     */
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferOpenGLESCompatibilityKey,
                             [NSDictionary dictionary], kCVPixelBufferIOSurfacePropertiesKey,
                             @(frameSize.width), kCVPixelBufferWidthKey,
                             @(frameSize.height), kCVPixelBufferHeightKey,
                             @(kCVPixelFormatType_32BGRA),kCVPixelBufferPixelFormatTypeKey,
                             nil];
    
    OSType bufferPixelFormat = kCVPixelFormatType_32BGRA;
//    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 2, NULL, NULL);
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,bufferPixelFormat, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage)), image.CGImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

+ (CVPixelBufferRef)pixelBufferFasterFromImage:(UIImage *)image {
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    size_t width =  CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
 
    CFDataRef  dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    GLubyte  *imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,width,height,kCVPixelFormatType_32BGRA,imageData,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
  
    CFRelease(dataFromImageDataProvider);
 
    return pxbuffer;
}

+ (CVPixelBufferRef)pixelBufferFromMatData:(void *)data {
    return NULL;//待完成
}

+ (CVPixelBufferRef)pixelBufferFasterFromImageData:(void *)data size:(CGSize)size sizePerRow:(size_t)sizePerRow {
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    size_t width =  size.width;
    size_t height = size.height;
    size_t bytesPerRow = sizePerRow;
 
    GLubyte  *imageData = (GLubyte *)data;
    //创建的格式：kCVPixelFormatType_32ARGB  kCVPixelFormatType_32BGRA
//    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,width,height,kCVPixelFormatType_32ARGB,imageData,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,width,height,kCVPixelFormatType_32BGRA,imageData,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
    return pxbuffer;
}

+ (CVPixelBufferRef)pixelBufferFromLayer:(CALayer *)layer {
    CGSize frameSize = CGSizeMake((int)layer.bounds.size.width,(int)layer.bounds.size.height);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES],
                             kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    /**
     UIKit － y轴向下
     Core Graphics(Quartz) － y轴向上
     OpenGL ES － y轴向上
     */
    CGContextTranslateCTM(context, 0, frameSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    [layer renderInContext:context];
    
    //调试查看
//    UIImage *viewImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
//    return viewImage;
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

///传入的layer比例为：480*640，要变成640*480
+ (CVPixelBufferRef)pixelBufferLeftLandscapeFromLayer:(CALayer *)layer frameSize:(CGSize)frameSize {
//    CGSize frameSize = CGSizeMake((int)layer.bounds.size.height,(int)layer.bounds.size.width);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES],
                             kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    /**
     UIKit － y轴向下
     Core Graphics(Quartz) － y轴向上
     OpenGL ES － y轴向上
     */
    CGContextTranslateCTM(context, 0, frameSize.width);
    CGContextScaleCTM(context, 1.0, -1.0);//翻转后，原点变为左上角(原来为左下角),saveState
    
    CGContextRotateCTM(context, DEGREES_TO_RADIANS(-90));//旋转后，x和y轴颠倒
    CGContextTranslateCTM(context, -frameSize.width, frameSize.width*0);
    
    CGContextTranslateCTM(context, frameSize.width/1.5, 0);
    CGContextScaleCTM(context, -1.0, 1.0);//翻转后，原点变为左上角(原来为左下角),saveState
    
    [layer renderInContext:context];
    
    //调试查看
//    UIImage *viewImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
//    return viewImage;
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

#pragma mark - < get image >
+ (UIImage *)imageFromPixelBuffer:(CVImageBufferRef)imageBuffer {
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGImageRelease(quartzImage);//释放
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    return image;
}

+ (UIImage *)imageFromPixelBufferWithRotation90:(CVImageBufferRef)imageBuffer {
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    /**
     UIKit － y轴向下
     Core Graphics(Quartz) － y轴向上
     OpenGL ES － y轴向上
     */
//    CGContextTranslateCTM(context, -width, 0);
//    CGContextScaleCTM(context, 1.0, -1.0);//翻转后，原点变为左上角(原来为左下角),saveState
//
//    CGContextRotateCTM(context, DEGREES_TO_RADIANS(90));
//    CGContextTranslateCTM(context, -width*0, -width*1);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    image = [ImageConvertor imageRotate:image];
    
    CGImageRelease(quartzImage);//释放
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    return image;
}

+ (UIImage *)scaleImage:(UIImage *)imgage maxLength:(CGFloat)length {
    CGFloat fixelW = CGImageGetWidth(imgage.CGImage);
    CGFloat fixelH = CGImageGetHeight(imgage.CGImage);
    if (MAX(fixelW, fixelH) < length) {
        return imgage;
    }

    CGFloat sacale = length/MAX(fixelW, fixelH);
    CGSize size = CGSizeMake(fixelW * sacale, fixelH * sacale);
    
    UIGraphicsBeginImageContext(size);
    [imgage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - < private >
///pixelBuffers是数组
+ (UIImage *)loadImage:(float*)pixelBuffers {
    
    NSUInteger width = 200;//这样写不通用，需要改成传入
    NSUInteger height = width;
    
    NSUInteger bytesPerPixel = 4;//返回的是3*256*256
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGColorSpace *colorSpace = CGColorSpaceCreateDeviceRGB();
    UInt32 *resultPixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    CGContextRef imageContext = CGBitmapContextCreate(resultPixels, width, height,
                                                 bitsPerComponent, bytesPerRow,
                                                colorSpace,
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    //rrrrrr  gggggg  bbbbbbb
    for (NSUInteger j = 0; j < height; j++) {
        for (NSUInteger i = 0; i < width; i++) {
            NSUInteger offset = j * width + i;
            UInt32 * resultPixel = resultPixels + offset;
            UInt32 newR = pixelBuffers[offset + width*width*0] * (255/2)+255/2;
            UInt32 newG = pixelBuffers[offset + width*width*1] *  (255/2)+255/2;
            UInt32 newB = pixelBuffers[offset + width*width*2] *  (255/2)+255/2;
            newR = MAX(0,MIN(255, newR));
            newG = MAX(0,MIN(255, newG));
            newB = MAX(0,MIN(255, newB));
            UInt32 resultColor = RGBAMake(newR, newG, newB, 255);
            *resultPixel = resultColor;
        }
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(imageContext);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(colorSpace);
    free(resultPixels);
    return resultImage;
}

//改成传入
+ (CVPixelBufferRef)pixelBufferFaster:(CVPixelBufferRef) imageBuffer {
    
    CVPixelBufferRef pxbuffer = NULL;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
    nil];
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    void* data = CVPixelBufferGetBaseAddress(imageBuffer);
//    unsigned char* data = [self flipBuffer:imageBuffer];
    //CVPixelBufferCreateWithBytes这个可以在时间上提高好几个数量级别，这是因为这里没有渲染也没有内存拷贝能耗时的操作而只是将data的指针进行了修改哦。
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,640,480,kCVPixelFormatType_32BGRA,data,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
    //观察是否有内存释放问题。有内存问题。
    return pxbuffer;

}

@end
