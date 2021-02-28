//
//  TextureModel.h
//  Poppy_Dev01
//
//  Created by jf on 2021/1/20.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextureModel : NSObject

@property(nonatomic, strong)NSString *url;//链接
@property(nonatomic, strong)NSString *path;//本地路径
@property(nonatomic, assign)GLubyte *texture;
@property(nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef buffer;
@property(nonatomic, assign)CGSize size;
@property(nonatomic, assign)size_t sizePerRow;

@end

NS_ASSUME_NONNULL_END
