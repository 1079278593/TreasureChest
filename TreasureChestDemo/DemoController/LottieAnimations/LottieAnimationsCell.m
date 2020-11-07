//
//  LottieAnimationsCell.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/23.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "LottieAnimationsCell.h"
#import "Lottie.h"

@interface LottieAnimationsCell ()

@property(nonatomic, strong)LOTAnimationView *lotView;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UIButton *playButton;

@end

@implementation LottieAnimationsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.contentView.layer.borderWidth = 1;
    }
    return self;
}

- (void)initView {
  
        
}

- (void)refreshCell:(NSString *)path {
    self.lotView = [[LOTAnimationView alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    [self.lotView playWithCompletion:^(BOOL animationFinished) {
        
    }];
    
    [self.contentView addSubview:self.lotView];
    [self.lotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.height.equalTo(self.contentView);
//        make.height.equalTo(@(120));
    }];
    
    self.nameLabel.text = [[path componentsSeparatedByString:@"/"]lastObject];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(30));
    }];
    
    [self.contentView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.height.equalTo(self.contentView);
    }];
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = UIColor.blackColor;
    }
    return _nameLabel;
}

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(playButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)playButtonEvent:(UIButton *)button {
    [self.lotView playWithCompletion:^(BOOL animationFinished) {
        
    }];
}

@end
