
attribute vec4 position;
//attribute mediump vec4 texturecoordinate;

uniform lowp vec4 vertexColor;

//下面是传给片段着色器
varying lowp vec4 color;
varying mediump vec2 coordinate;

void main()
{
    gl_Position = position;
    color = vertexColor;
//    coordinate = texturecoordinate.xy;
}
