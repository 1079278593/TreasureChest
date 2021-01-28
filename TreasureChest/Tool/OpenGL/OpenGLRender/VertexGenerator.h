//
//  VertexGenerator.h
//  TreasureChest
//
//  Created by jf on 2021/1/28.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VertexGenerator : NSObject

- (GLfloat *)faceVertexBuffer;
- (GLfloat *)faceTextureBuffer;
- (int)triangleCount;

@end

NS_ASSUME_NONNULL_END
