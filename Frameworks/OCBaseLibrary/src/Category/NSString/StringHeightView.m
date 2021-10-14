//
//  StringHeightView.m
//  Poppy_Dev01
//
//  Created by jf on 2020/8/28.
//  Copyright © 2020 YLQTec. All rights reserved.
//

#import "StringHeightView.h"

static StringHeightView *manager = nil;

@interface StringHeightView ()

@property(nonatomic, strong)UITextView *textView;

@end

@implementation StringHeightView

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[StringHeightView alloc]init];
    });
    return manager;
}

- (instancetype)init {
    if(self == [super init]){
        [self initView];
    }
    return self;
}

- (void)initView {
    _textView = [[UITextView alloc]init];
//    _textView.textContainer.lineFragmentPadding = 0;//去除左右边距
//    _textView.textContainerInset = UIEdgeInsetsMake(4, _textView.textContainerInset.left, _textView.textContainerInset.right, 4);//去除上下边距
    _textView.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);//去除上下边距
    [self addSubview:_textView];
}

- (CGFloat)stringHeightWithLine:(int)lineNum fontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth {
    lineNum = MAX(1, lineNum);
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i<lineNum; i++) {
        if (i == 0) {
            [string appendString:@"我"];
        }else {
            [string appendString:@"\n我"];
        }
    }
    return [self stringHeight:string fontSize:fontSize maxWidth:maxWidth];
}

- (CGFloat)stringHeight:(NSString *)string fontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth {
    _textView.frame = CGRectMake(0, 0, maxWidth, 100);//高度无所谓，因为内部是scrollView;
    _textView.font = [UIFont systemFontOfSize:fontSize];
    _textView.text = string;
    return _textView.contentSize.height;
}

@end
