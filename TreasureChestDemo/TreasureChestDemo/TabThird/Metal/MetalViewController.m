//
//  MetalViewController.m
//  TreasureChest
//
//  Created by imvt on 2024/3/13.
//  Copyright © 2024 xiao ming. All rights reserved.
//

#import "MetalViewController.h"
#import <MetalKit/MetalKit.h>
#import "EasyMetalRender.h"

@interface MetalViewController ()

@property(nonatomic, strong)MTKView *renderView;
@property(nonatomic, strong)EasyMetalRender *render;

@end

@implementation MetalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubViews];
    [self prepareRender];
}

#pragma mark - < <#expression#> >
- (void)prepareRender {
    //1.
    self.view = self.renderView;
    
    //2.为_view 设置MTLDevice，一个MTLDevice 对象就代表这着一个GPU,通常我们可以调用方法MTLCreateSystemDefaultDevice()来获取代表默认的GPU单个对象.
    _renderView.device = MTLCreateSystemDefaultDevice();
    
    //3.判断是否设置成功
    if (!_renderView.device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    
    //4. 创建自定义的渲染循环类
    //分开你的渲染循环:
    //在我们开发Metal 程序时,将渲染循环分为自己创建的类,是非常有用的一种方式,使用单独的类,我们可以更好管理初始化Metal,以及Metal视图委托.
    _render =[[EasyMetalRender alloc] initWithMetalKitView:_renderView];
    
    //5.判断_render 是否创建成功
    if (!_render) {
        NSLog(@"Renderer failed initialization");
        return;
    }
    
    //6.设置MTKView 的代理(由EasyMetalRender来实现MTKView 的代理方法)
    _renderView.delegate = _render;
    
    //7.视图可以根据视图属性上设置帧速率(指定时间来调用drawInMTKView方法--视图需要渲染时调用)
    _renderView.preferredFramesPerSecond = 60;
}

#pragma mark - < init view >
- (void)setupSubViews {
    self.renderView = [[MTKView alloc] initWithFrame:self.view.bounds];
}

@end
