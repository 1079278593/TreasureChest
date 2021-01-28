//
//  TextureDataManager.m
//  RosyWriter
//
//  Created by ming on 2016/9/26.
//
//

#import "TextureDataManager.h"

@implementation TextureDataManager

+ (void *)texturesDataWithImage:(UIImage *)image isFlip:(BOOL)isFlip {
    CGImageRef textureImage = image.CGImage;
    NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);

    void *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
                                                        texWidth, texHeight,
                                                        8, texWidth * 4,
                                                        CGImageGetColorSpace(textureImage),
                                                        kCGImageAlphaPremultipliedLast );
    if (isFlip) {
        CGContextTranslateCTM(textureContext, 0, texHeight);
        CGContextScaleCTM(textureContext, 1.0, -1.0);
    }
    
    CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
    CGContextRelease(textureContext);
    
    return textureData;
}

+ (void *)texturesUsingDataProviderWithImage:(UIImage *)image {
    CFDataRef rawdata = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    GLuint *pixels = (GLuint *)CFDataGetBytePtr(rawdata);
    return pixels;
}

@end
