//
//  TextureLoader.m
//  RosyWriter
//
//  Created by ming on 2016/9/26.
//
//

#import "TextureLoader.h"

@interface TextureLoader ()

@end

@implementation TextureLoader

#pragma mark - < public >
+ (void *)textureWithImage:(UIImage *)image isFlip:(BOOL)isFlip {
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

- (void *)textureUsingProvider:(UIImage *)image isFlip:(BOOL)isFlip {
    return [TextureLoader texturesDataWithImage:image isFlip:isFlip];
}

//返回的颜色不对，感觉像bgr
+ (void *)texturesDataWithImage:(UIImage *)image isFlip:(BOOL)isFlip {
    CFDataRef rawdata = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    GLuint *pixels = (GLuint *)CFDataGetBytePtr(rawdata);
    return pixels;
}

@end
