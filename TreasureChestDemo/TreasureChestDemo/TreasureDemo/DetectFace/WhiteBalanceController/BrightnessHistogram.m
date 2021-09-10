//
//  BrightnessHistogram.m
//  TreasureChest
//
//  Created by imvt on 2021/8/10.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "BrightnessHistogram.h"
#import <Accelerate/Accelerate.h>
#import "ImageConvertor.h"

#define KColorValue 255
@interface BrightnessHistogram () {
    CGContextRef _context;
    UInt32 * _pixels;
}

@property(nonatomic, strong)CAMLineChart *lineChart;

@end

@implementation BrightnessHistogram

- (void)dealloc
{
//    free(_pixels);//不能释放问题，待处理。
    CGContextRelease(_context);
}

#pragma mark - < public >
- (CAMLineChart*)getHistogramChartViewWithFrame:(CGRect)frame {
    
    CAMChartProfile *profile = [[CAMChartProfileManager shareInstance].defaultProfile mutableCopy];
    profile.xyAxis.showYGrid = YES;
    profile.xyAxis.showXGrid = NO;
    profile.lineChart.lineStyle = CAMChartLineStyleCurve;       //曲线样式

    CAMLineChart *chart = [[CAMLineChart alloc] initWithFrame:frame];
    chart.backgroundColor = [UIColor clearColor];
    
    chart.chartProfile = profile;
    chart.xUnit = @"亮度";
    chart.yUnit = @"数量";
    
    self.lineChart = chart;
    
    return chart;
}

///获取：亮度值
- (NSMutableArray *)brightnessFromPixelBuffer:(CVImageBufferRef)imageBuffer {
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    if (_context == NULL) {
        _pixels = CVPixelBufferGetBaseAddress(imageBuffer);
        _context = CGBitmapContextCreate(_pixels, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    }
    
    //统计亮度
//    int brt[256] = {0};
    NSMutableArray *brightness = [NSMutableArray arrayWithCapacity:256];
    for (int i = 0; i<256; i++) {
        [brightness addObject:@0];
    }
    UInt32 * currentPixel = _pixels;
    for (NSUInteger j = 0; j < height; j++) {
        for (NSUInteger i = 0; i < width; i++) {
            UInt32 color = *currentPixel;//app如果被挂起，再次进入时，这里需要处理，或者挂起时就终止这里的计算，待进入前台，重新启动。
            CGFloat value = (R(color)+G(color)+B(color))/3.0;
            brightness[(int)value] = @([brightness[(int)value] intValue] + 1);
            currentPixel++;
        }
    }
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    return brightness;
}

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

- (NSMutableArray *)brightnessWithVImageFromPixelBuffer:(CVImageBufferRef)imageBuffer  {    
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
    
    
    vImageCVImageFormatRef vformat = vImageCVImageFormat_CreateWithCVPixelBuffer( imageBuffer );
    // 首先，创建一个buffer，可以用vImage提供的CGImage的便携构造方法，里面需要传入原始数据所需要的format，这里就是ARGB8888
//    vImage_Error a_ret = vImageBuffer_InitWithCGImage(&a_buffer, &vImageFormatARGB8888, NULL, aImage, kvImageNoFlags);
    vImage_Error a_ret = vImageBuffer_InitWithCVPixelBuffer(&a_buffer, &vImageFormatARGB8888, imageBuffer, vformat, NULL, kvImageNoFlags);
    // 所有vImage的方法一般都有一个result，判断是否成功
    if (a_ret != kvImageNoError) return NULL;
    // 接着，我们需要对output buffer开辟内存，这里由于是RGB888，对应的rowBytes是3 * width，注意还需要64字节对齐，否则vImage处理会有额外的开销。
    
    dstBuffer_Yp.width = a_buffer.width;
    dstBuffer_Yp.height = a_buffer.height;
    dstBuffer_Yp.rowBytes = dstBuffer_Yp.width;
    dstBuffer_Yp.data = malloc(dstBuffer_Yp.rowBytes * dstBuffer_Yp.height);
    
    dstBuffer_CbCr.width = a_buffer.width;
    dstBuffer_CbCr.height = a_buffer.height;
    dstBuffer_CbCr.rowBytes = dstBuffer_CbCr.width;
    dstBuffer_CbCr.data = malloc(dstBuffer_CbCr.rowBytes * dstBuffer_CbCr.height);
    
    // 这里使用vImage的convert方法，转换色彩格式。YCbCr模型来源于YUV模型。YCbCr是 YUV 颜色空间的偏移版本
//    vImage_Error ret = vImageConvert_ARGB8888toRGB888(&a_buffer, &dstBuffer_Yp, kvImageNoFlags);
    
    //kvImageDoNotTile 、kvImageNoFlags、 kvImageNoAllocate
    vImage_Error ret = vImageConvert_ARGB8888To420Yp8_CbCr8(&a_buffer, &dstBuffer_Yp, &dstBuffer_CbCr, &info, NULL, kvImageDoNotTile);
    if (ret != kvImageNoError) return NULL;
    
    vImagePixelCount histogram[256] = {0};
    ret = vImageHistogramCalculation_Planar8(&dstBuffer_Yp, histogram, kvImageNoFlags);
    if (ret != kvImageNoError) return NULL;
    
    NSMutableArray *brightness = [NSMutableArray arrayWithCapacity:256];
    for (int i = 0; i<256; i++) {
        [brightness addObject:@(histogram[i])];
    }
    
    return brightness;
}
#pragma mark - < test >
- (NSMutableArray *)getlabels {
    NSMutableArray *labels =[NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<KColorValue; i++) {
        [labels addObject:[NSString stringWithFormat:@""]];
    }
    return labels;
}

- (NSMutableArray *)getTestDatas {
    NSMutableArray *datas =[NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<55; i++) {
        int index = arc4random() % 500 + 500;
        [datas addObject:@(index)];
    }
    
    for (int i = 0; i<80; i++) {
        int index = arc4random() % 200 + 200;
        [datas addObject:@(index)];
    }
    
    for (int i = 0; i<60; i++) {
        int index = arc4random() % 100 + 100;
        [datas addObject:@(index)];
    }
    
    for (int i = 0; i<60; i++) {
        int index = arc4random() % 300 + 300;
        [datas addObject:@(index)];
    }
    
    return datas;
}

@end
