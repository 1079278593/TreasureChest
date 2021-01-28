//
//  TextureDataManager.h
//  RosyWriter
//
//  Created by ming on 2016/9/26.
//
//

#import <Foundation/Foundation.h>

@interface TextureDataManager : NSObject

+ (void *)texturesDataWithImage:(UIImage *)image isFlip:(BOOL)isFlip;
+ (void *)texturesUsingDataProviderWithImage:(UIImage *)image;

@end
