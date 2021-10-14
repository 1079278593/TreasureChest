//
//  GenerateGif.m
//  ARCamera
//
//  Created by ming on 2021/9/21.
//

#import "GenerateGif.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>  //kUTTypeGIF的头文件

@implementation GenerateGif

#pragma mark - < 生成gif >
/**
 https://www.jianshu.com/p/857e50e9d947
 https://www.jianshu.com/p/52b2a87d6499
 参考：https://blog.csdn.net/qq_33140415/article/details/51325090
 */
+ (NSArray *)separateGifImagesFromVideoPath:(NSString *)path gifRateCount:(int)gifRateCount maxLength:(CGFloat)maxLength {
    NSURL *videoURL = [NSURL fileURLWithPath:path];
    
    // AVAssetImageGenerator
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;//必须设置，否则时间对应不上
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;//必须设置，否则时间对应不上

    NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
    NSError *error = nil;
    CMTime actualTime;
    
//    int gifRateCount = 10;//每秒取10帧，后面可以弄个滑块，让用户自己决定帧率
    int64_t count = CMTimeGetSeconds(asset.duration) * gifRateCount;
    int64_t delta = asset.duration.value / count;
    
    for (int i = 0; i < count; i++) {
        CMTime point = CMTimeMake(delta*i, asset.duration.timescale);
        CGImageRef centerFrameImage = [imageGenerator copyCGImageAtTime:point actualTime:&actualTime error:&error];

        if (centerFrameImage != NULL) {
            UIImage *image = [[UIImage alloc] initWithCGImage:centerFrameImage];
            image = [self scaleImage:image maxLength:maxLength];//压缩图片size，GIF限制最长边长度为300
            [images addObject:image];
            CGImageRelease(centerFrameImage);
        }
    }
    return images;
}

+ (NSString *)generateGifWithImages:(NSArray *)images interval:(CGFloat)interval {
    //构建在Document目录下的GIF文件路径
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [docs firstObject];
    NSString *gifPath = [NSString stringWithFormat:@"%@/target.gif",documentsDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:gifPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:gifPath error:nil];
    }
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)gifPath, kCFURLPOSIXPathStyle, NO);
    
    //4.通过一个url返回图像目标
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil);

    //CGImageDestinationCreateWithURL方法的作用是创建一个图片的目标对象，为了便于大家理解，这里把图片目标对象比喻为一个集合体。
    //集合体中描述了构成当前图片目标对象的一系列参数，如图片的URL地址、图片类型、图片帧数、配置参数等。
    //本代码中将mine.gif的本地文件路径作为参数1传递给这个图片目标对象，参数2描述了图片的类型为GIF图片，参数3表明当前GIF图片构成的帧数，参数4暂时给它一个空值。
    
    //5设置gif的信息，(播放时隔事件0.18)，基本数据和delay事件
    NSDictionary *delayTime = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:interval], (NSString *)kCGImagePropertyGIFDelayTime, nil];
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:delayTime
                                      forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    //设置gif信息
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCGImagePropertyGIFImageColorMap];
    
    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    
    [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString *)kCGImagePropertyDepth];
    
    [dict setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict forKey:(NSString *)kCGImagePropertyGIFDictionary];

    
    //6.合成gif（把所有图片遍历添加到图像目标）
    for (UIImage *dImg in images) {
        CGImageDestinationAddImage(destinationRef, dImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }

    //7、给gif添加信息
    CGImageDestinationSetProperties(destinationRef, (__bridge CFDictionaryRef)gifProperties);

    //8、写入gif图
    CGImageDestinationFinalize(destinationRef);

    //9、释放目标图像
    CFRelease(destinationRef);
    
    return gifPath;
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

@end
