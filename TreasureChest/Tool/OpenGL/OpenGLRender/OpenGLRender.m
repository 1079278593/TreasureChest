//
//  OpenGLFaceMaskRender.m
//  Poppy_Dev01
//
//  Created by jf on 2020/10/17.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "OpenGLRender.h"
#import <OpenGLES/EAGL.h>
#import "ShaderUtilities.h"
#import "fileUtil.h"
#import "matrix.h"

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@interface OpenGLRender ()
{
    EAGLContext *_oglContext;
    CVOpenGLESTextureCacheRef _pixelCache;
    CVOpenGLESTextureCacheRef _faceMaskCache;
    CVPixelBufferPoolRef _bufferPool;
    CFDictionaryRef _bufferPoolAuxAttributes;
    CMFormatDescriptionRef _outputFormatDescription;
    GLuint _offscreenBufferHandle;
    GLuint _program;
    GLint _videoframe;
    GLuint _faceframe;//面具
}

@end

@implementation OpenGLRender

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        _oglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if ( ! _oglContext ) {
            NSLog( @"Problem with OpenGL context." );
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [self reset];
}

#pragma mark - < public  >
- (CVPixelBufferRef)renderFaceMaskToPixelBuffer:(CVPixelBufferRef)pixelBuffer generator:(VertexGenerator *)vertexGenerator {
    static const GLfloat captureVertices[] = {
        -1.0f, -1.0f,   0.0f, 0.0f, // bottom left
         1.0f, -1.0f,   1.0f, 0.0f, // bottom right
        -1.0f,  1.0f,   0.0f, 1.0f, // top left
         1.0f,  1.0f,   1.0f, 1.0f, // top right
    };
    
    
    GLfloat *faceVertices = [vertexGenerator faceVertexBuffer];
    GLfloat *faceTexture = [vertexGenerator faceTextureBuffer];

    if ( _offscreenBufferHandle == 0 ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unintialized buffer" userInfo:nil];
        return NULL;
    }
    
    if ( pixelBuffer == NULL ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL pixel buffer" userInfo:nil];
        return NULL;
    }
    
    const CMVideoDimensions srcDimensions = { (int32_t)CVPixelBufferGetWidth(pixelBuffer), (int32_t)CVPixelBufferGetHeight(pixelBuffer) };
    const CMVideoDimensions dstDimensions = CMVideoFormatDescriptionGetDimensions( _outputFormatDescription );
    if ( srcDimensions.width != dstDimensions.width || srcDimensions.height != dstDimensions.height ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid pixel buffer dimensions" userInfo:nil];
        return NULL;
    }
    
    if ( CVPixelBufferGetPixelFormatType( pixelBuffer ) != kCVPixelFormatType_32BGRA ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid pixel buffer format" userInfo:nil];
        return NULL;
    }
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return NULL;
        }
    }
    
    CVReturn err = noErr;
    CVOpenGLESTextureRef srcTexture = NULL;
    CVOpenGLESTextureRef dstTexture = NULL;
    CVPixelBufferRef dstPixelBuffer = NULL;
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage( kCFAllocatorDefault,
                                                       _pixelCache,
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
        goto bail;
    }
    
    err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &dstPixelBuffer );
    if ( err == kCVReturnWouldExceedAllocationThreshold ) {
        // Flush the texture cache to potentially release the retained buffers and try again to create a pixel buffer
        // 纹理缓存刷新到潜在释放留存缓冲并再次尝试创建一个像素缓冲区
        CVOpenGLESTextureCacheFlush( _faceMaskCache, 0 );
        //这个函数创建一个新的CVPixelBuffer使用像素缓冲区池创建过程中指定属性和辅助属性中指定的属性参数。
        err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &dstPixelBuffer );
    }
    if ( err ) {
        if ( err == kCVReturnWouldExceedAllocationThreshold ) {
            NSLog( @"Pool is out of buffers, dropping frame" );
        }
        else {
            NSLog( @"Error at CVPixelBufferPoolCreatePixelBuffer %d", err );
        }
        goto bail;
    }

    err = CVOpenGLESTextureCacheCreateTextureFromImage( kCFAllocatorDefault,
                                                       _faceMaskCache,
                                                       dstPixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       dstDimensions.width,
                                                       dstDimensions.height,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &dstTexture );
    
    if ( ! dstTexture || err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err );
        goto bail;
    }
    
    glBindFramebuffer( GL_FRAMEBUFFER, _offscreenBufferHandle );
    glViewport( 0, 0, srcDimensions.width, srcDimensions.height );
    glUseProgram( _program );
    
    //开放混合模式
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // 设置目标像素的帧缓冲器的缓冲,渲染的目标。
    glActiveTexture( GL_TEXTURE0 );
    glBindTexture( CVOpenGLESTextureGetTarget( dstTexture ), CVOpenGLESTextureGetName( dstTexture ) );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget( dstTexture ), CVOpenGLESTextureGetName( dstTexture ), 0 );
    //glFramebufferTexture2D()把一幅纹理图像关联到一个FBO(frame buffer object),FBO本身并没有图像数据存储区，只有多个关联

    glUniform1i( _videoframe, 1 );//将采样器"videoframe"定位到GL_TEXTURE1
    
    // 绘制视频流
    glActiveTexture( GL_TEXTURE1 );
    glBindTexture( CVOpenGLESTextureGetTarget( srcTexture ), CVOpenGLESTextureGetName( srcTexture ) );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    glVertexAttribPointer( ATTRIB_VERTEX, 2, GL_FLOAT, 0, 4 * sizeof ( GLfloat ), captureVertices );
    glEnableVertexAttribArray( ATTRIB_VERTEX );
    glVertexAttribPointer( ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 4 * sizeof ( GLfloat ), &captureVertices[2] );
    glEnableVertexAttribArray( ATTRIB_TEXTUREPOSITON );
//    NSLog(@"测试时间：1");
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
//    NSLog(@"测试时间：2");
    
    //绘制面具
    if (faceVertices != NULL) {
        GLubyte *texture = NULL;//待传入，或者改造
        CGSize size;
        
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _faceframe);
        
//        NSLog(@"测试时间：3");
        //glTexImage2D会将原图像数据拷贝一份交由OpenGL自己管理,此时可以释放原图像数据。（看怎么弄只加载一次。）
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture);// Load the texture
//        NSLog(@"测试时间：4");
        
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        
        glVertexAttribPointer( ATTRIB_VERTEX, 2, GL_FLOAT, 0, 2 * sizeof ( GLfloat ), faceVertices );//这里的顶点，在Pipeline里做了旋转。
        glEnableVertexAttribArray( ATTRIB_VERTEX );
        glVertexAttribPointer( ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 2 * sizeof ( GLfloat ), faceTexture );
        glEnableVertexAttribArray( ATTRIB_TEXTUREPOSITON );
        
        glDrawArrays( GL_TRIANGLES, 0, [vertexGenerator triangleCount]*3 );
       
    }
    

    //将绑定标志位改为0，代表未绑定
    glBindTexture( CVOpenGLESTextureGetTarget( srcTexture ), 0 );
    glBindTexture( CVOpenGLESTextureGetTarget( dstTexture ), 0 );
    glBindTexture( _faceframe, 0 );
    
    // 确保渲染到目标像素缓冲区的未完成的GL命令已经提交。
    // AVAssetWriter, AVSampleBufferDisplayLayer, and GL 将阻塞，直到从像素缓冲区渲染完成。
    glFlush();
    
bail:
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
    if ( srcTexture ) {
        CFRelease( srcTexture );
    }
    if ( dstTexture ) {
        CFRelease( dstTexture );
    }
    
//    [vertexGenerator cleanFaceTextureAndVertex];
    
    return dstPixelBuffer;
}

#pragma mark - < private >


#pragma mark - < init >
///初始的准备宽高之类
- (void)prepareForInputWithFormatDescription:(CMFormatDescriptionRef)inputFormatDescription {
    [self reset];//这里？
    // 输入和输出尺寸都是一样的。这个渲染器不做任何扩展。
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions( inputFormatDescription );
    if (![self initializeBuffersWithOutputDimensions:dimensions retainedBufferCountHint:RETAINED_BUFFER_COUNT] ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem preparing renderer." userInfo:nil];
    }
}

- (BOOL)initializeBuffersWithOutputDimensions:(CMVideoDimensions)outputDimensions retainedBufferCountHint:(size_t)clientRetainedBufferCountHint
{
    BOOL success = YES;
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return NO;
        }
    }
    
    glDisable( GL_DEPTH_TEST );
    
    //帧缓存
    glGenFramebuffers( 1, &_offscreenBufferHandle );
    glBindFramebuffer( GL_FRAMEBUFFER, _offscreenBufferHandle );
    
    //纹理缓存
    CVReturn err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_pixelCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        success = NO;
        goto bail;
    }
    
    //面具缓存
    err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_faceMaskCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        success = NO;
        goto bail;
    }

    // Load vertex and fragment shaders
    GLint attribLocation[NUM_ATTRIBUTES] = {
        ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITON,
    };
    GLchar *attribName[NUM_ATTRIBUTES] = {
        "position", "texturecoordinate",
    };
    
    char *vsrc = readFile(pathForResource("faceMask.vsh"));
    char *fsrc = readFile(pathForResource("faceMask.fsh"));
    
    // shader program
    glueCreateProgram( vsrc, fsrc,
                      NUM_ATTRIBUTES, (const GLchar **)&attribName[0], attribLocation,
                      0, 0, 0,
                      &_program );
    if ( ! _program ) {
        NSLog( @"Problem initializing the program." );
        success = NO;
        goto bail;
    }
    _videoframe = glueGetUniformLocation( _program, "videoframe" );
    
    size_t maxRetainedBufferCount = clientRetainedBufferCountHint;
    _bufferPool = createPixelBufferPool( outputDimensions.width, outputDimensions.height, [self inputPixelFormat], (int32_t)maxRetainedBufferCount );
    if ( ! _bufferPool ) {
        NSLog( @"Problem initializing a buffer pool." );
        success = NO;
        goto bail;
    }
    
    _bufferPoolAuxAttributes = createPixelBufferPoolAuxAttributes( (int32_t)maxRetainedBufferCount );
    preallocatePixelBuffersInPool( _bufferPool, _bufferPoolAuxAttributes );
    
    CMFormatDescriptionRef outputFormatDescription = NULL;
    CVPixelBufferRef testPixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &testPixelBuffer );
    if ( ! testPixelBuffer ) {
        NSLog( @"Problem creating a pixel buffer." );
        success = NO;
        goto bail;
    }
    CMVideoFormatDescriptionCreateForImageBuffer( kCFAllocatorDefault, testPixelBuffer, &outputFormatDescription );
    _outputFormatDescription = outputFormatDescription;
    CFRelease( testPixelBuffer );
    
bail:
    if ( ! success ) {
        [self reset];
    }
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
    return success;
}

- (CMFormatDescriptionRef)outputFormatDescription
{
    return _outputFormatDescription;
}

- (FourCharCode)inputPixelFormat
{
    return kCVPixelFormatType_32BGRA;
}

///重置
- (void)reset
{
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return;
        }
    }
    if ( _offscreenBufferHandle ) {
        glDeleteFramebuffers( 1, &_offscreenBufferHandle );
        _offscreenBufferHandle = 0;
    }
    if ( _program ) {
        glDeleteProgram( _program );
        _program = 0;
    }
    if ( _pixelCache ) {
        CFRelease( _pixelCache );
        _pixelCache = 0;
    }
    if ( _faceMaskCache ) {
        CFRelease( _faceMaskCache );
        _faceMaskCache = 0;
    }
    if ( _bufferPool ) {
        CFRelease( _bufferPool );
        _bufferPool = NULL;
    }
    if ( _bufferPoolAuxAttributes ) {
        CFRelease( _bufferPoolAuxAttributes );
        _bufferPoolAuxAttributes = NULL;
    }
    if ( _outputFormatDescription ) {
        CFRelease( _outputFormatDescription );
        _outputFormatDescription = NULL;
    }
    if ( _faceframe) {
        glDeleteBuffers(1, &_faceframe);
    }
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
}

#pragma mark - < buffer pool >
static CVPixelBufferPoolRef createPixelBufferPool( int32_t width, int32_t height, FourCharCode pixelFormat, int32_t maxBufferCount )
{
    CVPixelBufferPoolRef outputPool = NULL;
    
    NSDictionary *sourcePixelBufferOptions = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(pixelFormat),
                                                (id)kCVPixelBufferWidthKey : @(width),
                                                (id)kCVPixelBufferHeightKey : @(height),
                                                (id)kCVPixelFormatOpenGLESCompatibility : @(YES),
                                                (id)kCVPixelBufferIOSurfacePropertiesKey : @{ /*empty dictionary*/ } };
    
    NSDictionary *pixelBufferPoolOptions = @{ (id)kCVPixelBufferPoolMinimumBufferCountKey : @(maxBufferCount) };
    
    CVPixelBufferPoolCreate( kCFAllocatorDefault, (__bridge CFDictionaryRef)pixelBufferPoolOptions, (__bridge CFDictionaryRef)sourcePixelBufferOptions, &outputPool );
    
    return outputPool;
}

static CFDictionaryRef createPixelBufferPoolAuxAttributes( int32_t maxBufferCount )
{
    // 如果我们已经提供了缓冲区的最大数量，那么cvpixelbufferwithauxattributes()将返回kcvreturn将超过allocationthreshold
    return CFRetain( (__bridge CFTypeRef)(@{ (id)kCVPixelBufferPoolAllocationThresholdKey : @(maxBufferCount) }) );
}

static void preallocatePixelBuffersInPool( CVPixelBufferPoolRef pool, CFDictionaryRef auxAttributes )
{
    // 预先分配池中的缓冲区，因为这是为了实时显示/捕获
    NSMutableArray *pixelBuffers = [[NSMutableArray alloc] init];
    while ( 1 )
    {
        CVPixelBufferRef pixelBuffer = NULL;
        OSStatus err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, pool, auxAttributes, &pixelBuffer );
        
        if ( err == kCVReturnWouldExceedAllocationThreshold ) {
            break;
        }
        assert( err == noErr );
        
        [pixelBuffers addObject:(__bridge id)pixelBuffer];
        CFRelease( pixelBuffer );
    }
}

@end
