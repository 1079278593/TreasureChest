//
//  TestPytorch.m
//  TreasureChest
//
//  Created by jf on 2021/1/7.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "TestPytorch.h"
#import <LibTorch/LibTorch.h>

@interface TestPytorch (){
    
    void *imageBuffer;
    
    @protected
    torch::jit::script::Module _impl;
}

@end

@implementation TestPytorch
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadModule];
        
    }
    return self;
}

-(void)loadModule
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"douyin8" ofType:@"pt"];
    const char *cString = (char *)[path cStringUsingEncoding:NSUTF8StringEncoding];
    
    std::vector<at::QEngine> qengines = at::globalContext().supportedQEngines();
    if (std::find(qengines.begin(), qengines.end(), at::QEngine::QNNPACK) != qengines.end()) {
        at::globalContext().setQEngine(at::QEngine::QNNPACK);
    }
    
    _impl = torch::jit::load(cString);
    _impl.eval();
    
//    torch::jit::script::Module module = torch::jit::load(cString);
//    return module;
}

#pragma mark - < public >
- (void)testBlob {
    at::Tensor inputTensor = torch::from_blob(imageBuffer, {1, 200, 200, 3}, at::kFloat);
    torch::autograd::AutoGradMode guard(false);
    at::AutoNonVariableTypeMode non_var_type_mode(true);
    auto outputTensor = _impl.forward({inputTensor}).toTensor();
    float * result = outputTensor.data_ptr<float>();

}

#pragma mark - < private >

@end
