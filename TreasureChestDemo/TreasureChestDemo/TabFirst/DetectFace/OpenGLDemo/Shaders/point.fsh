
uniform sampler2D sampleTexture;

varying mediump vec2 coordinate;

void main()
{
    gl_FragColor = vec4(1,1,1,0.8) * texture2D(sampleTexture, coordinate);
//    float tmp = coordinate.x;
//    gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
//    gl_FragColor = color;
}
