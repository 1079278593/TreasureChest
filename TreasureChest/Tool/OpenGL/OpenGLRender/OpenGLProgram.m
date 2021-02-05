//
//  OpenGLProgram.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/3.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "OpenGLProgram.h"
#import "fileUtil.h"
#import "ShaderUtilities.h"

@implementation OpenGLProgram

- (BOOL)createProgram:(NSString *)vshName fshName:(NSString*)fshName {
    return [self createProgram:vshName fshName:fshName lutImagePath:@""];
}

- (BOOL)createProgram:(NSString *)vshName fshName:(NSString*)fshName lutImagePath:(NSString*)lutImagePath {

    GLint attribLocation[NUM_ATTRIBUTES] = {
        ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITON,
    };
    GLchar *attribName[NUM_ATTRIBUTES] = {
        "position", "texturecoordinate",
    };//shader对应的命名要check
    
    char *vsrc = readFile(pathForResource([vshName UTF8String]));
    char *fsrc = readFile(pathForResource([fshName UTF8String]));
    
    glueCreateProgram( vsrc, fsrc,
                      NUM_ATTRIBUTES, (const GLchar **)&attribName[0], attribLocation,
                      0, 0, 0,
                      &_program );
    
    if ( ! _program ) {
        NSLog( @"Error creating the program" );
        return NO;
    }
    
    //这样做不适合shader多而且输入多的情况，目前可以适用。
    _displayFrame = glueGetUniformLocation( _program, "displayTexture" );//shader对应的命名要check
    if (lutImagePath.length > 0) {
        _lutFrame = glueGetUniformLocation( _program, "lutTexture" );
    }
    return YES;
}

- (void)deleteProgram {
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

@end
