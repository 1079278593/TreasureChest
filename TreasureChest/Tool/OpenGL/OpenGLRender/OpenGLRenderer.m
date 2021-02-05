//
//  OpenGLRenderer.m
//  Poppy_Dev01
//
//  Created by jf on 2021/2/3.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "OpenGLRenderer.h"
#import <OpenGLES/EAGL.h>
#import "ShaderUtilities.h"
#import "fileUtil.h"
#import "matrix.h"


@interface OpenGLRenderer ()
{
//    CVOpenGLESTextureCacheRef _inputCache;
    CVOpenGLESTextureCacheRef _targetCache;
    
    CVPixelBufferPoolRef _bufferPool;
    CFDictionaryRef _bufferPoolAuxAttributes;
    CMFormatDescriptionRef _outputFormatDescription;
    
    GLuint _frameBufferHandle;
//    CVOpenGLESTextureRef _dstTexture;
    CVPixelBufferRef _dstPixelBuffer;
    
    GLuint _colorBufferHandle;//考虑是否需要
}

@end

@implementation OpenGLRenderer

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

#pragma mark - < public >
///初始的准备宽高之类
- (void)prepareForInputWithFormatDescription:(CMFormatDescriptionRef)inputFormatDescription {
    // 输入和输出尺寸都是一样的。这个渲染器不做任何扩展。
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions( inputFormatDescription );
    if (![self initializeBuffersWithOutputDimensions:dimensions] ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem preparing renderer." userInfo:nil];
    }
}

- (void)setProgramGenerator:(OpenGLProgram *)programGenerator {
    _programGenerator = programGenerator;
}

- (CMFormatDescriptionRef)outputFormatDescription
{
    return _outputFormatDescription;
}

- (BOOL)startRender {
    _dstPixelBuffer = NULL;
    if (_dstTexture) {
        CFRelease( _dstTexture );
    }
    
    if ( _frameBufferHandle == 0 ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unintialized buffer" userInfo:nil];
        return NULL;
    }
    
    const CMVideoDimensions dstDimensions = CMVideoFormatDescriptionGetDimensions( _outputFormatDescription );
    
    _oldContext = [EAGLContext currentContext];
    if ( _oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return NO;
        }
    }
    
    CVReturn err = noErr;
    
    err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &_dstPixelBuffer );
    if ( err == kCVReturnWouldExceedAllocationThreshold ) {
        // Flush the texture cache to potentially release the retained buffers and try again to create a pixel buffer
        // 纹理缓存刷新到潜在释放留存缓冲并再次尝试创建一个像素缓冲区
        CVOpenGLESTextureCacheFlush( _targetCache, 0 );
        //这个函数创建一个新的CVPixelBuffer使用像素缓冲区池创建过程中指定属性和辅助属性中指定的属性参数。
        err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &_dstPixelBuffer );
    }
    if ( err ) {
        if ( err == kCVReturnWouldExceedAllocationThreshold ) {
            NSLog( @"Pool is out of buffers, dropping frame" );
        }
        else {
            NSLog( @"Error at CVPixelBufferPoolCreatePixelBuffer %d", err );
        }
        return NO;
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage( kCFAllocatorDefault,
                                                       _targetCache,
                                                       _dstPixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       dstDimensions.width,
                                                       dstDimensions.height,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_dstTexture );
    
    if ( ! _dstTexture || err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err );
        return NO;
    }
    
    glBindFramebuffer( GL_FRAMEBUFFER, _frameBufferHandle );
    glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget( _dstTexture ), CVOpenGLESTextureGetName( _dstTexture ), 0 );
    
    return YES;
}

- (CVPixelBufferRef)finish {
    if ( _oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:_oldContext];
    }
    
    //将绑定标志位改为0，代表未绑定
    glBindTexture( CVOpenGLESTextureGetTarget( _dstTexture ), 0 );
    
    if (_dstTexture) {//正常情况是渲染一次就释放，但是如果要多次绘制结果做为最后的结果，该不该释放呢，会不受pool的影响，count不够等。
        CFRelease( _dstTexture );
    }
    
    return _dstPixelBuffer;
}

- (void)reset {
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return;
        }
    }
    if ( _frameBufferHandle ) {
        glDeleteFramebuffers( 1, &_frameBufferHandle );
        _frameBufferHandle = 0;
    }
    
    [self.programGenerator deleteProgram];
    
    if ( _inputCache ) {
        CFRelease( _inputCache );
        _inputCache = 0;
    }
    if ( _targetCache ) {
        CFRelease( _targetCache );
        _targetCache = 0;
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
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
}

#pragma mark - < private >
- (FourCharCode)inputPixelFormat
{
    return kCVPixelFormatType_32BGRA;
}

- (BOOL)initializeBuffersWithOutputDimensions:(CMVideoDimensions)outputDimensions
{
    BOOL success = YES;
    
    if (![self generateBuffer]) {
        success = NO;
        goto bail;//生成buffer失败
    }

    if (self.programGenerator == nil) {
        self.programGenerator = [[OpenGLProgram alloc]init];
        success = [self.programGenerator createProgram:@"universal.vsh" fshName:@"universal.fsh"];
        if (!success) {
            goto bail;//创建program失败
        }
    }
    
    success = [self loadPixelBufferPool:outputDimensions.width outputDimensionsHeight:outputDimensions.height];
    if (!success) {
        goto bail;//加载pixelBufferPool失败
    }
    
bail:
    if ( ! success ) {
        [self reset];
    }
    return success;
}

- (BOOL)generateBuffer {
    EAGLContext *oldContext = [EAGLContext currentContext];
    if ( oldContext != _oglContext ) {
        if ( ! [EAGLContext setCurrentContext:_oglContext] ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Problem with OpenGL context" userInfo:nil];
            return NO;
        }
    }
    
    glDisable( GL_DEPTH_TEST );
    
    //帧缓存
    glGenFramebuffers( 1, &_frameBufferHandle );
    glBindFramebuffer( GL_FRAMEBUFFER, _frameBufferHandle );
    
    //输入缓存
    CVReturn err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_inputCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        return NO;
    }
    
    //渲染结果缓存
    err = CVOpenGLESTextureCacheCreate( kCFAllocatorDefault, NULL, _oglContext, NULL, &_targetCache );
    if ( err ) {
        NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        return NO;
    }
    
    if ( oldContext != _oglContext ) {
        [EAGLContext setCurrentContext:oldContext];
    }
    return YES;
}

- (BOOL)loadPixelBufferPool:(int32_t)width outputDimensionsHeight:(int32_t)height {
    size_t maxRetainedBufferCount = RETAINED_BUFFER_COUNT;
    _bufferPool = createPixelBufferPool(width, height, [self inputPixelFormat], (int32_t)maxRetainedBufferCount );
    if ( ! _bufferPool ) {
        NSLog( @"Problem initializing a buffer pool." );
        return NO;
    }
    
    _bufferPoolAuxAttributes = createPixelBufferPoolAuxAttributes( (int32_t)maxRetainedBufferCount );
    preallocatePixelBuffersInPool( _bufferPool, _bufferPoolAuxAttributes );
    
    CMFormatDescriptionRef outputFormatDescription = NULL;
    CVPixelBufferRef testPixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _bufferPool, _bufferPoolAuxAttributes, &testPixelBuffer );
    if ( ! testPixelBuffer ) {
        NSLog( @"Problem creating a pixel buffer." );
        return NO;
    }
    CMVideoFormatDescriptionCreateForImageBuffer( kCFAllocatorDefault, testPixelBuffer, &outputFormatDescription );
    _outputFormatDescription = outputFormatDescription;
    CFRelease( testPixelBuffer );
    return YES;
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
