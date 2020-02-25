//
//  VideoPlayerCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "VideoPlayerCtl.h"
#import "VideoPlayerSampleView.h"

@interface VideoPlayerCtl ()

@end

@implementation VideoPlayerCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    VideoPlayerSampleView *playerView = [[VideoPlayerSampleView alloc]init];
    [self.view addSubview:playerView];
    playerView.frame = CGRectMake(0, 64, KScreenWidth, 300);
    playerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    playerView.layer.borderWidth = 1;
    
    NSString *path = @"/Users/xiaoming/Downloads/haizeiwang.mp4";
    [playerView setupPlayer:path];
}



@end
