//
//  BaseNavigationController.m
//  cigarette
//
//  Created by xiao ming on 2020/1/9.
//  Copyright © 2020 by.huang. All rights reserved.
//

#import "BaseNavigationController.h"
#import "RetailPage.h"

@interface BaseNavigationController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak BaseNavigationController *weakSelf = self;
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate= weakSelf;
    }
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count >= 1) {
        [super pushViewController:viewController animated:animated];
        viewController.navigationController.interactivePopGestureRecognizer.enabled = YES;
        viewController.navigationController.interactivePopGestureRecognizer.delegate = nil;
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

//防侧滑卡死：https://www.jianshu.com/p/b3f333c2a525
- (void)navigationController:(UINavigationController*)navigationController didShowViewController:(UIViewController*)viewController animated:(BOOL)animate {
    NSArray* ctrlArray = navigationController.viewControllers;
    if(ctrlArray.count>1) {
        if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }else{
        if([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    if([viewController isKindOfClass:[RetailPage class]]){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}


@end
