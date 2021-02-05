//
//  FaceMaskRenderer.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/3.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "FaceMaskRenderer.h"
#import <OpenGLES/EAGL.h>
#import "ShaderUtilities.h"
#import "fileUtil.h"
#import "matrix.h"
#import "TextureLoader.h"

@implementation FaceMaskRenderer

- (void)renderWithProgram:(OpenGLProgram *)program pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    OpenGLProgram *targetProgram = program == nil ? self.programGenerator : program;
    
    if ( pixelBuffer == NULL ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL pixel buffer" userInfo:nil];
//        return NULL;
    }
    
    const CMVideoDimensions srcDimensions = { (int32_t)CVPixelBufferGetWidth(pixelBuffer), (int32_t)CVPixelBufferGetHeight(pixelBuffer) };
    const CMVideoDimensions dstDimensions = CMVideoFormatDescriptionGetDimensions( self.outputFormatDescription );
    if ( srcDimensions.width != dstDimensions.width || srcDimensions.height != dstDimensions.height ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid pixel buffer dimensions" userInfo:nil];
//        return NULL;
    }
    
    if ( CVPixelBufferGetPixelFormatType( pixelBuffer ) != kCVPixelFormatType_32BGRA ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid pixel buffer format" userInfo:nil];
//        return NULL;
    }
    //前面的这些判断，看情况，包成一个函数，或者不判断。有的是CVPixelBufferRef，有的是mat,有的是image
    
    static const GLfloat vertices[] = {
        -1.0f, -1.0f,   0.0f, 0.0f, // bottom left
         1.0f, -1.0f,   1.0f, 0.0f, // bottom right
        -1.0f,  1.0f,   0.0f, 1.0f, // top left
         1.0f,  1.0f,   1.0f, 1.0f, // top right
    };//可尝试配置方向的方式
    
    CVReturn err = noErr;
    CVOpenGLESTextureRef srcTexture = NULL;    
    err = CVOpenGLESTextureCacheCreateTextureFromImage( kCFAllocatorDefault,
                                                       self.inputCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       srcDimensions.width,
                                                       srcDimensions.height,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &srcTexture );
    if ( ! srcTexture || err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err );
        
        //这里怎么处理，’雪花‘？
    }
    
    
    glViewport( 0, 0, dstDimensions.width, dstDimensions.height );
    glUseProgram( targetProgram.program );
    
    //开放混合模式
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // 设置目标像素的帧缓冲器的缓冲,渲染的目标。
    glActiveTexture( GL_TEXTURE0 );
    glBindTexture( CVOpenGLESTextureGetTarget( self.dstTexture ), CVOpenGLESTextureGetName( self.dstTexture ) );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    
    
    glUniform1i( targetProgram.displayFrame, 1 );//将采样器"XXX"定位到GL_TEXTURE1
    glActiveTexture( GL_TEXTURE1 );
    glBindTexture( CVOpenGLESTextureGetTarget( srcTexture ), CVOpenGLESTextureGetName( srcTexture ) );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    glVertexAttribPointer( ATTRIB_VERTEX, 2, GL_FLOAT, 0, 4 * sizeof ( GLfloat ), vertices );
    glEnableVertexAttribArray( ATTRIB_VERTEX );
    glVertexAttribPointer( ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 4 * sizeof ( GLfloat ), &vertices[2] );
    glEnableVertexAttribArray( ATTRIB_TEXTUREPOSITON );
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    
    // 确保渲染到目标像素缓冲区的未完成的GL命令已经提交。
    // AVAssetWriter, AVSampleBufferDisplayLayer, and GL 将阻塞，直到从像素缓冲区渲染完成。
    glFlush();
    
    //将绑定标志位改为0，代表未绑定
    glBindTexture( CVOpenGLESTextureGetTarget( srcTexture ), 0 );
//    [vertexGenerator cleanFaceTextureAndVertex];
    
    if ( srcTexture ) {
        CFRelease( srcTexture );
    }//src可以立马释放。
}

- (void)renderWithProgram:(OpenGLProgram *)program image:(UIImage *)image {
    OpenGLProgram *targetProgram = program == nil ? self.programGenerator : program;
    
    //前面的这些判断，看情况，包成一个函数，或者不判断。有的是CVPixelBufferRef，有的是mat,有的是image
    
    static const GLfloat vertices[] = {
        -1.0f, -1.0f,   0.0f, 0.0f, // bottom left
         1.0f, -1.0f,   1.0f, 0.0f, // bottom right
        -1.0f,  0.0f,   0.0f, 1.0f, // top left
         1.0f,  0.0f,   1.0f, 1.0f, // top right
    };//可尝试配置方向的方式
    
    const CMVideoDimensions dstDimensions = CMVideoFormatDescriptionGetDimensions( self.outputFormatDescription );
    glViewport( 0, 0, dstDimensions.width, dstDimensions.height );
    glUseProgram( targetProgram.program );
    
    //开放混合模式
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // 设置目标像素的帧缓冲器的缓冲,渲染的目标。
    glActiveTexture( GL_TEXTURE0 );
    glBindTexture( CVOpenGLESTextureGetTarget( self.dstTexture ), CVOpenGLESTextureGetName( self.dstTexture ) );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    
    
    glUniform1i( targetProgram.displayFrame, 1 );
    GLubyte *texture = [TextureLoader textureWithImage:image isFlip:NO];;
    GLuint textureId;
    glGenTextures(1, &textureId);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
//        NSLog(@"测试时间：3");
    //glTexImage2D会将原图像数据拷贝一份交由OpenGL自己管理,此时可以释放原图像数据。（看怎么弄只加载一次。）
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture);// Load the texture
//        NSLog(@"测试时间：4");
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    glVertexAttribPointer( ATTRIB_VERTEX, 2, GL_FLOAT, 0, 2 * sizeof ( GLfloat ), vertices );//这里的顶点，在Pipeline里做了旋转。
    glEnableVertexAttribArray( ATTRIB_VERTEX );
    glVertexAttribPointer( ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 2 * sizeof ( GLfloat ), vertices );
    glEnableVertexAttribArray( ATTRIB_TEXTUREPOSITON );
    
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    
    // 确保渲染到目标像素缓冲区的未完成的GL命令已经提交。
    // AVAssetWriter, AVSampleBufferDisplayLayer, and GL 将阻塞，直到从像素缓冲区渲染完成。
    glFlush();
    
    //将绑定标志位改为0，代表未绑定
//    glBindTexture( CVOpenGLESTextureGetTarget( srcTexture ), 0 );
//    [vertexGenerator cleanFaceTextureAndVertex];
    
    if ( textureId) {
        glDeleteBuffers(1, &textureId);
    }
}

@end
