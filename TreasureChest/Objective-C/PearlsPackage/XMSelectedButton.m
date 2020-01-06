//
//  XMSelectedButton.m
//  cigarette
//
//  Created by xiao ming on 2019/12/23.
//  Copyright © 2019 by.huang. All rights reserved.
//

#import "XMSelectedButton.h"
#import <Masonry.h>

@interface XMSelectedButton()
@property(assign, nonatomic)CGFloat imageWH;
@property(assign, nonatomic)CGFloat fontSize;
@end

@implementation XMSelectedButton

//- (instancetype)initWithFrame:(CGRect)frame {
//    if(self == [super initWithFrame:frame]){
//        [self initView];
//        _imageWH = STHeight(13);
//        _fontSize = STFont(14);
//        _alignment = ImageAlignmentRight;
//        [self initView];
//    }
//    return self;
//}
//
//- (void)initView {
//    _selectedLabel = [[UILabel alloc]initWithFontFamily:[UIFont fontWithName:FONT_REGULAR size:_fontSize] text:MSG_EMPTY textAlignment:NSTextAlignmentCenter textColor:c10 backgroundColor:nil multiLine:NO];
//    [self addSubview:_selectedLabel];
//
//    _iconImageView = [[UIImageView alloc]init];
//    _iconImageView.image = [UIImage imageNamed:IMAGE_REFRESH];
//    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self addSubview:_iconImageView];
//}
//
//- (void)showWithText:(NSString *)text {
//    _selectedLabel.textAlignment = _alignment == ImageAlignmentLeft ? NSTextAlignmentLeft :NSTextAlignmentRight;
//    _selectedLabel.text = text;
//    
//    CGFloat textWidth = [text sizeWithMaxWidth:ScreenWidth font:_fontSize fontName:FONT_REGULAR].width;
//    if (_alignment == ImageAlignmentLeft) {
//        _iconImageView.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - _imageWH)/2.0, _imageWH, _imageWH);
//        _selectedLabel.frame = CGRectMake(_iconImageView.right + STWidth(6), 0, CGRectGetWidth(self.frame) - (_iconImageView.right + STWidth(6)), self.height);
//    }else {
//        _selectedLabel.frame = CGRectMake(0, 0, textWidth, self.height);
//        _iconImageView.frame = CGRectMake(_selectedLabel.right + STWidth(6), (CGRectGetHeight(self.frame) - _imageWH)/2.0, _imageWH, _imageWH);
//    }
//}

@end
