
attribute vec4 position;
attribute mediump vec2 texCoord;


//下面是传给片段着色器
varying mediump vec2 coordinate;

void main()
{
    gl_Position = position;
    coordinate = texCoord;
}
