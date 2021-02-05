//
//  FaceMaskRenderer.h
//  Poppy_Dev01
//
//  Created by jf on 2021/2/3.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "OpenGLRenderer.h"
//#import "VertexGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceMaskRenderer : OpenGLRenderer

//'图‘，’位置‘，’program‘
- (void)renderWithProgram:(OpenGLProgram *)program pixelBuffer:(CVPixelBufferRef)pixelBuffer;
//- (void)renderWithProgram:(OpenGLProgram *)program image:(UIImage *)image generator:(VertexGenerator *)vertexGenerator;
- (void)renderWithProgram:(OpenGLProgram *)program image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
