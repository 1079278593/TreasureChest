//
//  PixelsOperator.m
//  TreasureChest
//
//  Created by jf on 2021/1/5.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "PixelsOperator.h"
#import <Accelerate/Accelerate.h>

@implementation PixelsOperator

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
//pixelBuffers为：RGB
- (UIImage *)loadBGRAImage:(UIImage *)inputImage width:(NSUInteger)width height:(NSUInteger)height {
    // 1. Get the raw pixels of the image
    UInt32 * inputPixels;
    
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    for (NSUInteger j = 0; j < height; j++) {
        for (NSUInteger i = 0; i < width; i++) {
            NSUInteger offset = j * width + i;
            UInt32 *inputPixel = inputPixels + offset;
            UInt32 inputColor = *inputPixel;
            
            UInt32 newR = R(inputColor);
            UInt32 newG = G(inputColor);
            UInt32 newB = B(inputColor);
            
            newR = MAX(0,MIN(255, newR));
            newG = MAX(0,MIN(255, newG));
            newB = MAX(0,MIN(255, newB));
            UInt32 resultColor = RGBAMake(newB, newG, newR, 255);
            *inputPixel = resultColor;
        }
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return resultImage;
}

- (NSData *)getBGRWithImage:(UIImage *)image
{
    int RGBA = 4;
    int RGB  = 3;
    
    CGImageRef imageRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    char *m = (char *)malloc(sizeof(char)*100);
    m[0] = "3";
    m[1] = "43";
    m[2] = "53";
    unsigned char *rawData = (unsigned char *) malloc(width * height * sizeof(unsigned char) * RGBA);
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    unsigned char * tempRawData = (unsigned char *)malloc(width * height * 3 * sizeof(unsigned char));
    
    for (int i = 0; i < width * height; i ++) {
        
        NSUInteger byteIndex = i * RGBA;
        NSUInteger newByteIndex = i * RGB;
        
        // Get RGB
        CGFloat red    = rawData[byteIndex + 0];
        CGFloat green  = rawData[byteIndex + 1];
        CGFloat blue   = rawData[byteIndex + 2];
        //CGFloat alpha  = rawData[byteIndex + 3];// 这里Alpha值是没有用的
        
        // Set RGB To New RawData
        tempRawData[newByteIndex + 0] = blue;   // B
        tempRawData[newByteIndex + 1] = green;  // G
        tempRawData[newByteIndex + 2] = red;    // R
    }
    
    NSData *data = [NSData dataWithBytes:tempRawData length:(width * height * 3 * sizeof(unsigned char))];
    return data;
}

#pragma mark - < private 待封装 >
///创建CVPixelBuffer，将data指针直接挂上去。  https://blog.csdn.net/whf727/article/details/18706153
- (CVPixelBufferRef)pixelBufferFaster:(CVPixelBufferRef) imageBuffer {
    
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];//[NSNumber numberWithInt : 480],kCVPixelBufferWidthKey,kCVPixelBufferHeightKey
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
 
    unsigned char*data = [self flipBuffer:imageBuffer];
    //CVPixelBufferCreateWithBytes这个可以在时间上提高好几个数量级别，这是因为这里没有渲染也没有内存拷贝能耗时的操作而只是将data的指针进行了修改哦。
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,width,height,kCVPixelFormatType_32ARGB,data,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
    //观察是否有内存释放问题。有内存问题。
    return pxbuffer;

}

///https://zhuanlan.zhihu.com/p/31001201?from_voters_page=true
- (unsigned char*) flipBuffer: (CVPixelBufferRef) imageBuffer
{
// CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
 CVPixelBufferLockBaseAddress(imageBuffer,0);

 size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
 size_t width = CVPixelBufferGetWidth(imageBuffer);
 size_t height = CVPixelBufferGetHeight(imageBuffer);
 size_t currSize = bytesPerRow*height*sizeof(unsigned char);

 void *srcBuff = CVPixelBufferGetBaseAddress(imageBuffer);
 unsigned char *outBuff = (unsigned char*)malloc(currSize);

 vImage_Buffer ibuff = { srcBuff, height, width, bytesPerRow};
 vImage_Buffer ubuff = { outBuff, height, width, bytesPerRow};

 vImage_Error err= vImageHorizontalReflect_ARGB8888(&ibuff, &ubuff, kvImageHighQualityResampling);
 if (err != kvImageNoError) NSLog(@"%ld", err);
    
 return outBuff;
}

///https://www.it1352.com/917049.html
- (unsigned char*) rotateBuffer: (CVPixelBufferRef) imageBuffer
{
// CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
 CVPixelBufferLockBaseAddress(imageBuffer,0);

 size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
 size_t width = CVPixelBufferGetWidth(imageBuffer);
 size_t height = CVPixelBufferGetHeight(imageBuffer);
 size_t currSize = bytesPerRow*height*sizeof(unsigned char);
 size_t bytesPerRowOut = 4*height*sizeof(unsigned char);

 void *srcBuff = CVPixelBufferGetBaseAddress(imageBuffer);
 unsigned char *outBuff = (unsigned char*)malloc(currSize);

 vImage_Buffer ibuff = { srcBuff, height, width, bytesPerRow};
 vImage_Buffer ubuff = { outBuff, width, height, bytesPerRowOut};
 Pixel_8888 clear_color = {0};
 uint8_t rotConst = 1;   // 0, 1, 2, 3 is equal to 0, 90, 180, 270 degrees rotation
 vImage_Error err = vImageRotate90_ARGB8888(&ibuff, &ubuff, NULL, clear_color, kvImageBackgroundColorFill | kvImageHighQualityResampling);
// vImage_Error err= vImageRotate90_ARGB8888 (&ibuff, &ubuff, NULL, rotConst, NULL,0);
 if (err != kvImageNoError) NSLog(@"%ld", err);

 return outBuff;
}

@end
