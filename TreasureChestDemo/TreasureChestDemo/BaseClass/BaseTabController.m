//
//  BaseTabController.m
//  TreasureChest
//
//  Created by ming on 2021/4/11.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "BaseTabController.h"

@interface BaseTabController ()<UITabBarDelegate,UITabBarControllerDelegate>

@end

@implementation BaseTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    //没效果
    //set up crossfade transition
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    //apply transition to tab bar controller's view
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

@end
