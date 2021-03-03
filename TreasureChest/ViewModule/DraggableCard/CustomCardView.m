//
//  CustomCardView.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/20.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "CustomCardView.h"

@interface CustomCardView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel     *titleLabel;

@end

@implementation CustomCardView

- (instancetype)init {
    if (self = [super init]) {
        [self loadComponent];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadComponent];
    }
    return self;
}

#pragma mark - < public >
- (void)refreshWithData:(NSDictionary *)element {
    NSLog(@"installData %@",element);
    self.imageView.image  = [UIImage imageNamed:element[@"image"]];
    self.titleLabel.text = element[@"title"];
}

#pragma mark - < private >
- (void)loadComponent {
    self.imageView = [[UIImageView alloc] init];
    self.titleLabel = [[UILabel alloc] init];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView.layer setMasksToBounds:YES];
    
    self.titleLabel.textColor = [UIColor redColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    
    self.backgroundColor = [UIColor colorWithRed:0.951 green:0.951 blue:0.951 alpha:1.00];
}

- (void)cc_layoutSubviews {
    self.imageView.frame   = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 64);
    self.titleLabel.frame = CGRectMake(0, self.frame.size.height - 64, self.frame.size.width, 64);
}

@end
