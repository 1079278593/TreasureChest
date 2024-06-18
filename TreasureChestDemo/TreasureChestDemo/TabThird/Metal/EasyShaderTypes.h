//
//  EasyShaderTypes.h
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#ifndef EasyShaderTypes_h
#define EasyShaderTypes_h

typedef enum CCVertexInputIndex {
    CCVertexInputIndexVertices     = 0, //!< 顶点
    CCVertexInputIndexViewportSize = 1, //!< 视图大小
} CCVertexInputIndex;


//结构体: 顶点/颜色值
typedef struct {
    // 像素空间的位置
    // 像素中心点(100,100)
    vector_float4 position;

    // RGBA颜色
    vector_float4 color;
} ShaderVertex;

#endif /* EasyShaderTypes_h */
