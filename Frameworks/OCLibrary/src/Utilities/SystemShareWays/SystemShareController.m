//
//  SystemShareController.m
//  ARCamera
//
//  Created by ming on 2021/10/16.
//

#import "SystemShareController.h"
#import "EasyProgress.h"

@implementation SystemShareController

//先弹出系统，然后点击微信。
- (void)sharePictureSystemWay:(UIViewController *)controller {
    UIImage *imageToShareOne = [UIImage imageNamed:@"22.gif"];
    UIImage *imageToShareTwo = [UIImage imageNamed:@"Escape"];
    
    NSArray *activityItems = @[imageToShareOne, imageToShareTwo];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    [controller presentViewController:activityVC animated:TRUE completion:nil];
}

- (void)shareVideoSystemWay:(UIViewController *)controller path:(NSString *)path {
    [EasyProgress showLoading:@"正在生成..."];
    NSURL *videoURL = [NSURL fileURLWithPath:path];
    NSArray *activityItems = @[videoURL];
    NSLog(@"------1232");
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [controller presentViewController:activityVC animated:YES completion:^{
        [EasyProgress hide];
    }];
}

- (void)shareGifSystemWay:(UIViewController *)controller path:(NSString *)path {
    path = [[NSBundle mainBundle]pathForResource:@"22" ofType:@"gif"];
    NSData *date = [NSData dataWithContentsOfFile:path];
    NSArray *activityItems = @[[NSURL fileURLWithPath:path]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [controller presentViewController:activityVC animated:YES completion:nil];
}

/**
 - (void)sharePictureSystemEasyWay:(UIViewController *)controller {
     NSString *test = @"com.tencent.xin.sharetimeline";
     if (![SLComposeViewController isAvailableForServiceType:test]) {
         NSLog(@"或者没有配置相关的帐号");
         return;
     }
     
     // 2.创建分享的控制器
     self.composeController = [SLComposeViewController composeViewControllerForServiceType:test];
     if (self.composeController == nil){
         NSLog(@"没有安装微信");
         return;
     }
     // 2添加图片
     [self.composeController addImage:[UIImage imageNamed:@"1,2,3,4"]];
     [self.composeController addImage:[UIImage imageNamed:@"Escape"]];
     
     // 3.弹出分享控制器（以Modal形式弹出）
     UIViewController * rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
     [rootVc presentViewController:self.composeController animated:TRUE completion:nil];
     
     // 4.监听用户点击了取消还是发送
     
      //SLComposeViewControllerResultCancelled,
      //SLComposeViewControllerResultDone
      
     self.composeController.completionHandler = ^(SLComposeViewControllerResult result){
         if (result == SLComposeViewControllerResultCancelled) {
             NSLog(@"点击了取消");
         } else {
             NSLog(@"点击了发送");
         }
     };
 }

 */

@end
