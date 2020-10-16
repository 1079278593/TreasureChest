//
//  OpenGLView.m
//  TreasureChest
//
//  Created by jf on 2020/10/16.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "OpenGLView.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import "fileUtil.h"
#import "ShaderUtilities.h"
#import "TextureDataManager.h"

///每行代表[x, y,   s,t]。两个三角形组成正方向
GLfloat squareVertexData[] = {
     0.5f,0.5f,  1.0f,1.0f,     //右上
    -0.5f,0.5f,  0.0f,1.0f,     //左上
    0.5f,-0.5f,  1.0f,0.0f,     //右下
    
    0.5f,-0.5f,  1.0f,0.0f,     //右下
    -0.5f,0.5f,  0.0f,1.0f,     //左上
   -0.5f,-0.5f,  0.0f,0.0f      //左下
};

enum {
    ATTRIB_Position,
    ATTRIB_TexCoord,
    NUM_ATTRIBS
};

enum {
//    UNIFORM_VertexColor,
    UNIFORM_SampleTexture,
    NUM_UNIFORMS
};

@interface OpenGLView () {
    
    GLuint program;
    GLint uniform[NUM_UNIFORMS];
    GLfloat brushColor[4];
    GLuint textureId;
    
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;
    GLuint depthRenderbuffer;
    GLuint vboId;
    
    GLuint textureLocation;
}


@end

@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self == [super initWithFrame:frame]){
        if ([self initContext]) {
            [self initGL];
            [self setupShaders];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setUpViewport];
    [self erase];
}

#pragma mark - < public >
- (void)drawTriangle {
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_DYNAMIC_DRAW);
    
    glVertexAttribPointer(ATTRIB_Position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
    glVertexAttribPointer(ATTRIB_TexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL+2*sizeof(GLfloat));
    
    glEnableVertexAttribArray(ATTRIB_Position);
    glEnableVertexAttribArray(ATTRIB_TexCoord);
    
    // Bind the texture
    glActiveTexture ( GL_TEXTURE0 );
    glBindTexture ( GL_TEXTURE_2D, textureId );
    // Set the sampler texture unit to 0
    glUniform1i ( uniform[UNIFORM_SampleTexture], 0 );
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    //EACAGLContext 渲染OpenGL绘制好的图像到EACAGLLayer
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)showTextureTriangle {
//    [self genTextureWithImage:[UIImage imageNamed:@"face3"]];
//    [self drawTriangle];
        
    [self tmpDrawImage];
}

#pragma mark - < OpenGL 初始化设置 >
- (BOOL)initContext {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    // 在这个应用程序中，我们希望在调用presentRenderbuffer之后保留EAGLDrawable内容。
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!context || ![EAGLContext setCurrentContext:context]) {
        NSLog(@"Fail to set current context");
        return NO;
    }
    
    /**
     //这个scale会影响backingWidth和backingHeight
     在函数setUpViewport里，glGetRenderbufferParameteriv 获取的  backingWidth 会乘以这个 scale
     */
    double scale = [[UIScreen mainScreen] scale];
    self.contentScaleFactor = scale;
    return YES;
}

- (BOOL)initGL {
    // 为framebuffer对象和颜色渲染缓冲区生成id
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    //这个调用将当前渲染缓冲区的存储与EAGLDrawable(我们的CAEAGLLayer)关联起来。
    //允许我们绘制到缓冲区，稍后将渲染到屏幕上的任何层(这与我们的视图相对应)。
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);//将渲染缓冲区挂载到当前帧缓冲区上
    
    /*
     *参考：https://www.jianshu.com/p/d7066d6a02cc
     
     一个完整的帧缓冲需要满足以下的条件：

     附加至少一个缓冲（颜色、深度或模板缓冲）。
     至少有一个颜色附件(Attachment)。
     所有的附件都必须是完整的（保留了内存）。
     每个缓冲都应该有相同的样本数。
     */
    
    //检查帧缓冲是否完整。
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    
    // 创建一个顶点缓冲对象来保存我们的数据
    glGenBuffers(1, &vboId);
    
    
    // 启用混合和设置一个混合函数适当的预乘alpha像素数据
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    return YES;
}

- (void)setupShaders {
    char *vsrc = readFile(pathForResource("point.vsh"));
    char *fsrc = readFile(pathForResource("point.fsh"));
    
    GLsizei attribCount = 0;//
    GLchar *attribUsed[NUM_ATTRIBS];
    GLint attrib[NUM_ATTRIBS];
    GLchar *attribName[NUM_ATTRIBS] = {
        "position","texCoord",
    };
    const GLchar *uniformName[NUM_UNIFORMS] = {
//        "vertexColor",
        "sampleTexture",
    };
    
    // 自动分配已知的自然属性
    for (int j = 0; j < NUM_ATTRIBS; j++)
    {
        if (strstr(vsrc, attribName[j])) //判断attribName是否在顶点着色器中出现的字符串
        {
            attrib[attribCount] = j;//设置属性的location，根据j来。
            attribUsed[attribCount++] = attribName[j];//attribCt传递自身值，结束后自增。
        }
    }
    
    //创建program、编译、连接、绑定location
    glueCreateProgram(vsrc, fsrc,
                      attribCount, (const GLchar **)&attribUsed[0], attrib,
                      NUM_UNIFORMS, &uniformName[0], uniform,
                      &program);
    
    glUseProgram(program);
    [self setUniformColor:[UIColor redColor]];
    
    free(vsrc);
    free(fsrc);
}

- (BOOL)setUpViewport {
    // 基于当前图层大小分配颜色缓冲
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    glViewport(0, 0, backingWidth, backingHeight);  // 更新窗口
    
    return YES;
}

- (void)erase {
    [EAGLContext setCurrentContext:context];
    // Clear the buffer
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - < helper >
- (void)setUniformColor:(UIColor *)newColor {
    CGFloat newRed, newGreen, newBlue, newAlpha;
    [newColor getRed:&newRed green:&newGreen blue:&newBlue alpha:&newAlpha];
    brushColor[0] = newRed ;
    brushColor[1] = newGreen;
    brushColor[2] = newBlue;
    brushColor[3] = 1;
//    glUniform4fv(uniform[UNIFORM_VertexColor], 1, brushColor);
}

- (GLuint)createTextureWithImage:(UIImage *)image {
    GLuint textureId;
    
    void *pixels = [TextureDataManager texturesDataWithImage:image isFlip:YES];
    
    int width = image.size.width;
    int height = image.size.height;
    
    // Use tightly packed data
    glPixelStorei ( GL_UNPACK_ALIGNMENT, 1 );
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    // Load the texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

    // 结束后要做清理
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    
    return textureId;
}

GLuint CreateSimpleTexture2D( )
{
   // Texture object handle
   GLuint textureId;

   // 2x2 Image, 3 bytes per pixel (R, G, B)
   GLubyte pixels[4 * 3] =
   {
      155,   0,   0, // Red
        0, 25,   0, // Green
        0,   0, 255, // Blue
      255, 255,   0  // Yellow
   };

   // Use tightly packed data
   glPixelStorei ( GL_UNPACK_ALIGNMENT, 1 );

   // Generate a texture object
   glGenTextures ( 1, &textureId );

   // Bind the texture object
   glBindTexture ( GL_TEXTURE_2D, textureId );

   // Load the texture
   glTexImage2D ( GL_TEXTURE_2D, 0, GL_RGB, 2, 2, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels );

   // Set the filtering mode
   glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
   glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );

   return textureId;
}

#pragma mark - < private >
#pragma mark < 简单三角形 >
- (void)tmpTriangel {
    glUseProgram(program);
    
    GLfloat attrArr[] =
    {
        1.0f, -0.5f, 0.0f,  // 右下
        0.0f, 0.5f, 0.0f,   // 上
        -1.0f, -0.5f, 0.0f  // 左下
    };
        
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    //将顶点坐标写入顶点VBO
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    // 获取参数索引
    GLuint position = glGetAttribLocation(program, "position");
    
    //告诉OpenGL该如何解析顶点数据
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    glEnableVertexAttribArray(position);
    
    //绘制三个顶点的三角形
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    //EACAGLContext 渲染OpenGL绘制好的图像到EACAGLLayer
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark < 简单图片 >

- (void)tmpDrawImage {

//    textureId = CreateSimpleTexture2D();
    textureId = [self createTextureWithImage:[UIImage imageNamed:@"128"]];///这里要改，到时可能是网络数据。：face3
    
    GLfloat vVertices[] = { -0.5f,  0.5f, 0.0f,  // Position 0   左上
                             0.0f,  1.0f,        // TexCoord 0
                            -0.5f, -0.5f, 0.0f,  // Position 1   左下
                             0.0f,  0.0f,        // TexCoord 1
                             0.5f, -0.5f, 0.0f,  // Position 2   右下
                             1.0f,  0.0f,        // TexCoord 2
                             0.5f,  0.5f, 0.0f,  // Position 3   右上
                             1.0f,  1.0f         // TexCoord 3
                          };
    GLushort indices[] = { 0, 1, 2, 0, 2, 3 };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vVertices), vVertices, GL_DYNAMIC_DRAW);
    
    
    glUseProgram ( program );

    
    glVertexAttribPointer ( ATTRIB_Position, 3, GL_FLOAT, GL_FALSE, 5 * sizeof ( GLfloat ), NULL );
    glVertexAttribPointer ( ATTRIB_TexCoord, 2, GL_FLOAT, GL_FALSE, 5 * sizeof ( GLfloat ), NULL+3*sizeof(GLfloat));
    glEnableVertexAttribArray ( ATTRIB_Position );
    glEnableVertexAttribArray ( ATTRIB_TexCoord );

    // Bind the texture
    glActiveTexture ( GL_TEXTURE0 );
    glBindTexture ( GL_TEXTURE_2D, textureId );

    // Set the sampler texture unit to 0
    glUniform1i ( UNIFORM_SampleTexture, 0 );

    glDrawElements ( GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, indices );
    
    //EACAGLContext 渲染OpenGL绘制好的图像到EACAGLLayer
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
