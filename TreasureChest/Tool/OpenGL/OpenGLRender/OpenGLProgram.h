//
//  OpenGLProgram.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/3.
//  Copyright © 2021 YLQTec. All rights reserved.
//  待增加一个program的manager，管理创建了的program

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLProgram : NSObject

@property(nonatomic, assign)GLuint program;
@property(nonatomic, assign)GLint displayFrame;
@property(nonatomic, assign)GLint lutFrame;

- (BOOL)createProgram:(NSString *)vshName fshName:(NSString*)fshName;
- (BOOL)createProgram:(NSString *)vshName fshName:(NSString*)fshName lutImagePath:(NSString*)lutImagePath;
- (void)deleteProgram;

@end

NS_ASSUME_NONNULL_END
