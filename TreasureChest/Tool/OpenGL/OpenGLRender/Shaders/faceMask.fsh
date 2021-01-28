
precision mediump float;

varying mediump vec2 coordinate;
uniform sampler2D videoframe;

void main()
{
    vec4 color = texture2D(videoframe, coordinate);
    gl_FragColor = vec4(1,1,1,1) * color;
//    gl_FragColor = vec4(color.b, color.g, color.r, color.a);
}
