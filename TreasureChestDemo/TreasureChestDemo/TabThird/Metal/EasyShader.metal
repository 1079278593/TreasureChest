//
//  EasyShader.metal
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//  https://www.jianshu.com/p/fa2dc9b64074

#include <metal_stdlib>
#import "EasyShaderTypes.h"

using namespace metal;

typedef struct {
    float4 clipSpacePosition [[position]];//处理空间的顶点信息， position的修饰符表示这个是顶点
    float4 color;//颜色
//    float2 textureCoordinate; // 纹理坐标，会做插值处理
} RasterizerData;

vertex RasterizerData  // 返回给片元着色器的结构体

//顶点着色函数
vertexShader(uint vertexID [[vertex_id]],
             constant ShaderVertex *vertices [[buffer(CCVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(CCVertexInputIndexViewportSize)]])
{
    //定义out
    RasterizerData out;
    //把输入的剪辑空间的位置直接赋值给输出位置 （由于这个例子传入的数据为归一化数据，不用到坐标系转换）
    out.clipSpacePosition = vertices[vertexID].position;
    /**
     （需要特别注意的是外部传入的顶点数据是归一化数据，所以我们直接赋值）
     而当外部传入的顶点数据是像素维度数据时，这一步需要换成以下操作转换坐标空间
     
    //1.初始化输出剪辑空间位置
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);

    //2.通过索引vertexID到我们的数组位置以获得当前顶点
    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    //3.将vierportSizePointer 从verctor_uint2 转换为vector_float2 类型
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);

    //4.每个顶点着色器的输出位置在剪辑空间中(也称为归一化设备坐标空间,NDC),剪辑空间中的(-1,-1)表示视口的左下角,而(1,1)表示视口的右上角.
    //计算和写入 XY值到我们的剪辑空间的位置.为了从像素空间中的位置转换到剪辑空间的位置,我们将像素坐标除以视口的大小的一半.
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
     */
    
    //把我们输入的颜色直接赋值给输出颜色。这个值将为构成三角形的顶点的其他颜色值插值，从而为我们片段着色器中的每个片段生成颜色值.
    out.color = vertices[vertexID].color;

    //将结构体传递到管道中下一个阶段
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    //返回输入的片元颜色
    return in.color;
}
