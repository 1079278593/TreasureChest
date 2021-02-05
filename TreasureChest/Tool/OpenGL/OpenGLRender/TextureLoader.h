//
//  TextureLoader.h
//  RosyWriter
//
//  Created by ming on 2016/9/26.
//
//

#import <Foundation/Foundation.h>

@interface TextureLoader : NSObject

//两种加载方式
+ (void *)textureWithImage:(UIImage *)image isFlip:(BOOL)isFlip;
- (void *)textureUsingProvider:(UIImage *)image isFlip:(BOOL)isFlip;

/* Conveniences */
+ (void *)texturesDataWithImage:(UIImage *)image isFlip:(BOOL)isFlip;

@end
