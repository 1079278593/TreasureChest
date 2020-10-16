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

@end

@implementation OpenGLController

- (void)viewDidLoad {
    [super viewDidLoad];
    OpenGLView *openGLView = [[OpenGLView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:openGLView];
    
}


@end
