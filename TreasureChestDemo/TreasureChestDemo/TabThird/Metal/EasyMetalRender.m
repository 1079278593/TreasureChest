//
//  EasyMetalRender.m
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//

/** 参考
 https://www.jianshu.com/p/fa2dc9b64074
 https://www.jianshu.com/p/a982201c49e5
 https://github.com/loyinglin/LearnMetal
 https://github.com/MetalPetal/MetalPetal
 */

#import "EasyMetalRender.h"
#import "EasyShaderTypes.h"

typedef struct {
    float red, green, blue, alpha;
} EasyColor;//创建颜色通道结构体

@interface EasyMetalRender () {
    id<MTLDevice> _device;//device是所有应用程序需要与GPU交互的第一个对象。用来渲染的设备(又名GPU)
    id<MTLCommandQueue> _commandQueue;
    
    // 我们的渲染管道有顶点着色器和片元着色器 它们存储在.metal shader 文件中
    id<MTLRenderPipelineState> _pipelineState;
    //当前视图大小,这样我们才可以在渲染通道使用这个视图
    vector_uint2 _viewportSize;
}

@end

@implementation EasyMetalRender

- (instancetype)initWithMetalKitView:(MTKView *)mtkView {
    if (self = [super init]) {
        /**
         MTLCommandQueue，使用MTLCommandQueue 去创建对象,并且加入MTLCommandBuffer 对象中。确保它们能够按照正确顺序发送到GPU。对于每一帧，一个新的MTLCommandBuffer对象创建并且填满了由GPU执行的命令。
         */
        //1.获取GPU 设备
        _device = mtkView.device;

        //2.在项目中加载所有的(.metal)着色器文件
        // 从bundle中获取.metal文件
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        //从库中加载顶点函数
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        //从库中加载片元函数
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];

        //3.配置用于创建管道状态的管道
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        //管道名称
        pipelineStateDescriptor.label = @"the Pipeline";
        //可编程函数,用于处理渲染过程中的各个顶点
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        //可编程函数,用于处理渲染过程中各个片段/片元
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        //一组存储颜色数据的组件
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        //4.同步创建并返回渲染管线状态对象
        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        //判断是否返回了管线状态对象
        if (!_pipelineState)
        {
           
            //如果我们没有正确设置管道描述符，则管道状态创建可能失败
            NSLog(@"Failed to created pipeline state, error %@", error);
            return nil;
        }

        //5.创建命令队列
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

#pragma mark - < public >

#pragma mark - < delegate >
/**
 主要步骤分为：

 1.设置清屏颜色
 2.为每个渲染传递创建一个新的命令缓冲区到当前绘制
 3.从视图绘制中,获得渲染描述符
 4.判断渲染描述符是否创建成功,成功则进行以下渲染操作，失败则直接执行第9步
 5.通过渲染描述符renderPassDescriptor创建MTLRenderCommandEncoder对象
 6.如果需要的话，使用MTLRenderCommandEncoder来绘制对象，这个案例我们不需要其他渲染，所以直接执行下一步
 7.结束MTLRenderCommandEncoder 工作
 8.添加一个最后的命令present用以显示可绘制的屏幕
 9.完成渲染并将命令缓冲区提交给GPU
 */

//每当视图需要渲染帧时调用
- (void)drawInMTKView:(nonnull MTKView *)view
{
    //1. 顶点数据/颜色数据
    //剪辑空间（归一化设备坐标空间）顶点数据
    static const ShaderVertex triangleVertices[] =
    {
        //顶点,    RGBA 颜色值
        { {  0.5, -0.25, 0.0, 1.0 }, { 1, 0, 0, 1 } },
        { { -0.5, -0.25, 0.0, 1.0 }, { 0, 1, 0, 1 } },
        { { -0.0f, 0.25, 0.0, 1.0 }, { 0, 0, 1, 1 } },
    };
    //像素空间顶点数据
//如果metal着色程序中的顶点数据是基于像素空间的，需要将归一化数据乘以视口大小的一半，转换成像素坐标
//    static const CCVertex triangleVertices[] =
//    {
//        //顶点,    RGBA 颜色值
//        { {  0.5*621.0, -0.5*552.0, 0.0, 1.0 }, { 1, 0, 0, 1 } },
//        { { -0.5*621.0, -0.5*552.0, 0.0, 1.0 }, { 0, 1, 0, 1 } },
//        { { -0.0f, 0.5*552.0, 0.0, 1.0 }, { 0, 0, 1, 1 } },
//    };

    //2.为当前渲染的每个渲染传递创建一个新的命令缓冲区
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    //指定缓存区名称
    commandBuffer.label = @"MyCommand";
    
    //3.
    // MTLRenderPassDescriptor:一组渲染目标，用作渲染通道生成的像素的输出目标。
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    //判断渲染目标是否为空
    if(renderPassDescriptor != nil)
    {
        //4.创建渲染命令编码器,这样我们才可以渲染到something
        id<MTLRenderCommandEncoder> renderEncoder =[commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        //渲染器名称
        renderEncoder.label = @"MyRenderEncoder";

        //5.设置我们绘制的可绘制区域
        /*
        typedef struct {
            double originX, originY, width, height, znear, zfar;
        } MTLViewport;
         */
        //视口指定Metal渲染内容的drawable区域。 视口是具有x和y偏移，宽度和高度以及近和远平面的3D区域
        //为管道分配自定义视口需要通过调用setViewport。 如果未指定视口，Metal会设置一个默认视口，其大小与用于创建渲染命令编码器的drawable相同。
        MTLViewport viewPort = {
            0.0,0.0,_viewportSize.x,_viewportSize.y,-1.0,1.0
        };
        [renderEncoder setViewport:viewPort];
        //[renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];
        
        //6.设置当前渲染管道状态对象
        [renderEncoder setRenderPipelineState:_pipelineState];
    
        
        //7.从应用程序OC 代码中发送数据给Metal顶点着色器函数
        //顶点数据+颜色数据
        //   1) 指向要传递给着色器的内存的指针
        //   2) 我们想要传递的数据的内存大小
        //   3)一个整数索引，它对应于我们的“vertexShader”函数中的缓冲区属性限定符的索引。

        [renderEncoder setVertexBytes:triangleVertices
                               length:sizeof(triangleVertices)
                              atIndex:CCVertexInputIndexVertices];

        //viewPortSize 数据
        //1) 发送到顶点着色函数中,视图大小
        //2) 视图大小内存空间大小
        //3) 对应的索引
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:CCVertexInputIndexViewportSize];

       
        
        //8.画出三角形的3个顶点
        // @method drawPrimitives:vertexStart:vertexCount:
        //@brief 在不使用索引列表的情况下,绘制图元
        //@param 绘制图形组装的基元类型
        //@param 从哪个位置数据开始绘制,一般为0
        //@param 每个图元的顶点个数,绘制的图型顶点数量
        /*
         MTLPrimitiveTypePoint = 0, 点
         MTLPrimitiveTypeLine = 1, 线段
         MTLPrimitiveTypeLineStrip = 2, 线环
         MTLPrimitiveTypeTriangle = 3,  三角形
         MTLPrimitiveTypeTriangleStrip = 4, 三角型扇
         */
    
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:3];

        //9.表示该编码器生成的命令都已完成,并且从MTLCommandBuffer中分离
        [renderEncoder endEncoding];

        //10.一旦框架缓冲区完成，使用当前可绘制的进度表
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    //11.最后,在这里完成渲染并将命令缓冲区推送到GPU
    [commandBuffer commit];
}


- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end



