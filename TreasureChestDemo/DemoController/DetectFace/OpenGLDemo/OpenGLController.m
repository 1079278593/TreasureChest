//
//  OpenGLController.m
//  TreasureChest
//
//  Created by jf on 2020/10/16.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "OpenGLController.h"
#import "OpenGLView.h"

@interface OpenGLController ()

@property(nonatomic, strong)OpenGLView *openGLView;

@end

@implementation OpenGLController

- (void)viewDidLoad {
    [super viewDidLoad];
    _openGLView = [[OpenGLView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_openGLView];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_openGLView showTextureTriangle];
}

@end
