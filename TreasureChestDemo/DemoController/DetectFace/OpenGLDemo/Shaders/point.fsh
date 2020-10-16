
uniform sampler2D videoframe;

varying lowp vec4 color;
varying highp vec2 coordinate;

void main()
{
//    gl_FragColor = texture2D(videoframe, coordinate);
//    float tmp = coordinate.x;
//    gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
    gl_FragColor = color;
}
