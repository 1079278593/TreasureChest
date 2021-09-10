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

///参考这个！！！图片编解码
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

#pragma mark - < VImage >
/**
 // 对于iOS使用的arm cpu是小端对齐的。
 //CGImageByteOrderInfo | CGImageAlphaInfo 组合后CGBitmapInfo 的颜色空间的格式
 CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaLast; // 像素存储格式0xABGR 像素类型RGBA
 CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst; // 像素存储格式0xBGRA 像素类型ARGB
 CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaLast; // 像素存储格式0xRGBA 像素类型RGBA
 CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaFirst; // 像素存储格式0xARGB 像素类型ARGB
 */
// 为了方便，我们首先直接定义好ARGB8888的format结构体，后续需要多次使用
static vImage_CGImageFormat vImageFormatARGB8888 = (vImage_CGImageFormat) {
    .bitsPerComponent = 8, // 8位
    .bitsPerPixel = 32, // ARGB4通道，4*8
    .colorSpace = NULL, // 默认就是sRGB
    .bitmapInfo = kCGImageAlphaFirst | kCGBitmapByteOrderDefault, // 表示ARGB
//    .bitmapInfo = (CGBitmapInfo)kCGImageAlphaFirst,
    .version = 0, // 或许以后会有版本区分，现在都是0
    .decode = NULL, // 和`CGImageCreate`的decode参数一样，可以用来做色彩范围映射的，NULL就是[0, 1.0]
    .renderingIntent = kCGRenderingIntentDefault, // 和`CGImageCreate`的intent参数一样，当色彩空间超过后如何处理
};

// RGB888的format结构体
static vImage_CGImageFormat vImageFormatRGB888 = (vImage_CGImageFormat) {
    .bitsPerComponent = 8, // 8位
    .bitsPerPixel = 24, // RGB3通道，3*8
    .colorSpace = NULL,
    .bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault, // 表示RGB
    .version = 0,
    .decode = NULL,
    .renderingIntent = kCGRenderingIntentDefault,
};
// 字节对齐使用，vImage如果不是64字节对齐的，会有额外开销
static inline size_t vImageByteAlign(size_t size, size_t alignment) {
    return ((size + (alignment - 1)) / alignment) * alignment;
}

+ (void)testVImage {
    UIImage *image = [UIImage imageNamed:@"face1"];
    CGImageRef newRef = [PixelsOperator nonAlphaImageWithImage:[image CGImage]];
    int width = CGImageGetWidth(newRef);
}

+ (CGImageRef)nonAlphaImageWithImage:(CGImageRef)aImage {
    // 首先，我们声明input和output的buffer
    __block vImage_Buffer a_buffer = {}, dstBuffer_Yp = {}, dstBuffer_CbCr = {};
    @onExit {
        // 由于vImage的API需要手动管理内存，避免内存泄漏
        // 为了方便错误处理清理内存，可以使用clang attibute的cleanup（这里是libextobjc的宏）
        // 如果不这样，还有一种方式，就是使用goto，定义一个fail:的label，所有return NULL改成`goto fail`;
        if (a_buffer.data) free(a_buffer.data);
        if (dstBuffer_Yp.data) free(dstBuffer_Yp.data);
        if (dstBuffer_CbCr.data) free(dstBuffer_CbCr.data);
    };
    
    
    static vImage_ARGBToYpCbCr info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vImage_YpCbCrPixelRange pixelRange = (vImage_YpCbCrPixelRange){ 0, 128, 255, 255, 255, 1, 255, 0 };
        vImageConvert_ARGBToYpCbCr_GenerateConversion(kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2, &pixelRange, &info, kvImageARGB8888, kvImage420Yp8_Cb8_Cr8, 0);
    });
    
    
    
    // 首先，创建一个buffer，可以用vImage提供的CGImage的便携构造方法，里面需要传入原始数据所需要的format，这里就是ARGB8888
    vImage_Error a_ret = vImageBuffer_InitWithCGImage(&a_buffer, &vImageFormatARGB8888, NULL, aImage, kvImageNoFlags);
    // 所有vImage的方法一般都有一个result，判断是否成功
    if (a_ret != kvImageNoError) return NULL;
    // 接着，我们需要对output buffer开辟内存，这里由于是RGB888，对应的rowBytes是3 * width，注意还需要64字节对齐，否则vImage处理会有额外的开销。
    
    dstBuffer_Yp.width = a_buffer.width;
    dstBuffer_Yp.height = a_buffer.height;
    dstBuffer_Yp.rowBytes = vImageByteAlign(dstBuffer_Yp.width * 1, 64);
    dstBuffer_Yp.data = malloc(dstBuffer_Yp.rowBytes * dstBuffer_Yp.height);
    
    dstBuffer_CbCr.width = a_buffer.width;
    dstBuffer_CbCr.height = a_buffer.height;
    dstBuffer_CbCr.rowBytes = vImageByteAlign(dstBuffer_CbCr.width * 1, 64);
    dstBuffer_CbCr.data = malloc(dstBuffer_CbCr.rowBytes * dstBuffer_CbCr.height);
    
    // 这里使用vImage的convert方法，转换色彩格式。YCbCr模型来源于YUV模型。YCbCr是 YUV 颜色空间的偏移版本
//    vImage_Error ret = vImageConvert_ARGB8888toRGB888(&a_buffer, &dstBuffer_Yp, kvImageNoFlags);
    
    //kvImageDoNotTile 、kvImageNoFlags
    vImage_Error ret = vImageConvert_ARGB8888To420Yp8_CbCr8(&a_buffer, &dstBuffer_Yp, &dstBuffer_CbCr, &info, NULL, kvImageDoNotTile);
    if (ret != kvImageNoError) return NULL;
    
    vImagePixelCount histogram[256] = {0};
    ret = vImageHistogramCalculation_Planar8(&dstBuffer_Yp, histogram, kvImageNoFlags);
    if (ret != kvImageNoError) return NULL;
    
    
    // 此时已经output buffer已经转换完成，输出回CGImage
    CGImageRef outputImage = vImageCreateCGImageFromBuffer(&dstBuffer_Yp, &vImageFormatRGB888, NULL, NULL, kvImageNoFlags, &ret);
    if (ret != kvImageNoError) return NULL;
    
    UIImage *img = [UIImage imageWithCGImage:outputImage];
    return outputImage;
}

void encodeRGBAToYUVA(uint8_t *yuva, uint8_t const *argb, int width, int height, int bytesPerRow) {
    static vImage_ARGBToYpCbCr info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vImage_YpCbCrPixelRange pixelRange = (vImage_YpCbCrPixelRange){ 0, 128, 255, 255, 255, 1, 255, 0 };
        vImageConvert_ARGBToYpCbCr_GenerateConversion(kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2, &pixelRange, &info, kvImageARGB8888, kvImage420Yp8_Cb8_Cr8, 0);
    });
    
    vImage_Error error = kvImageNoError;
    
    vImage_Buffer src;
    src.data = (void *)argb;
    src.width = width;
    src.height = height;
    src.rowBytes = bytesPerRow;
    
    uint8_t permuteMap[4] = {3, 2, 1, 0};
    error = vImagePermuteChannels_ARGB8888(&src, &src, permuteMap, kvImageDoNotTile);
    
    error = vImageUnpremultiplyData_ARGB8888(&src, &src, kvImageDoNotTile);
    
    uint8_t *alpha = yuva + width * height * 2;
    int i = 0;
    for (int y = 0; y < height; y += 1) {
        uint8_t const *argbRow = argb + y * bytesPerRow;
        for (int x = 0; x < width; x += 2) {
            uint8_t a0 = (argbRow[x * 4 + 0] >> 4) << 4;
            uint8_t a1 = (argbRow[(x + 1) * 4 + 0] >> 4) << 4;
            alpha[i / 2] = (a0 & (0xf0U)) | ((a1 & (0xf0U)) >> 4);
            i += 2;
        }
    }
    
    vImage_Buffer destYp;
    destYp.data = (void *)(yuva + 0);
    destYp.width = width;
    destYp.height = height;
    destYp.rowBytes = width;
    
    vImage_Buffer destCbCr;
    destCbCr.data = (void *)(yuva + width * height * 1);
    destCbCr.width = width;
    destCbCr.height = height;
    destCbCr.rowBytes = width;
    
    error = vImageConvert_ARGB8888To420Yp8_CbCr8(&src, &destYp, &destCbCr, &info, NULL, kvImageDoNotTile);
    if (error != kvImageNoError) {
        return;
    }
}

void decodeYUVAToRGBA(uint8_t const *yuva, uint8_t *argb, int width, int height, int bytesPerRow) {
    static vImage_YpCbCrToARGB info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vImage_YpCbCrPixelRange pixelRange = (vImage_YpCbCrPixelRange){ 0, 128, 255, 255, 255, 1, 255, 0 };
        vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_709_2, &pixelRange, &info, kvImage420Yp8_Cb8_Cr8, kvImageARGB8888, 0);
    });
    
    vImage_Error error = kvImageNoError;
    
    vImage_Buffer srcYp;
    srcYp.data = (void *)(yuva + 0);
    srcYp.width = width;
    srcYp.height = height;
    srcYp.rowBytes = width * 1;
    
    vImage_Buffer srcCbCr;
    srcCbCr.data = (void *)(yuva + width * height * 1);
    srcCbCr.width = width;
    srcCbCr.height = height;
    srcCbCr.rowBytes = width * 1;
    
    vImage_Buffer dest;
    dest.data = (void *)argb;
    dest.width = width;
    dest.height = height;
    dest.rowBytes = bytesPerRow;
    
    error = vImageConvert_420Yp8_CbCr8ToARGB8888(&srcYp, &srcCbCr, &dest, &info, NULL, 0xff, kvImageDoNotTile);
    
    uint8_t const *alpha = yuva + (width * height * 1 + width * height * 1);
    int i = 0;
    for (int y = 0; y < height; y += 1) {
        uint8_t *argbRow = argb + y * bytesPerRow;
        for (int x = 0; x < width; x += 2) {
            uint8_t a = alpha[i / 2];
            uint8_t a1 = (a & (0xf0U));
            uint8_t a2 = ((a & (0x0fU)) << 4);
            argbRow[x * 4 + 0] = a1 | (a1 >> 4);
            argbRow[(x + 1) * 4 + 0] = a2 | (a2 >> 4);
            i += 2;
        }
    }
    
    error = vImagePremultiplyData_ARGB8888(&dest, &dest, kvImageDoNotTile);
    
    uint8_t permuteMap[4] = {3, 2, 1, 0};
    error = vImagePermuteChannels_ARGB8888(&dest, &dest, permuteMap, kvImageDoNotTile);
    
    if (error != kvImageNoError) {
        return;
    }
}

@end
