//
//  NumberInputView.m
//  TreasureChest
//
//  Created by xiao ming on 2020/2/28.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "NumberInputView.h"
#import "UIButton+Extension.h"

@interface NumberInputView()
@property(assign, nonatomic)NSUInteger maxCount;
@property(assign, nonatomic)NSUInteger minCount;
@property(strong, nonatomic)UIButton *leftButton;
@property(strong, nonatomic)UIButton *rightButton;
@property(strong, nonatomic)UITextField *inputTextField;
@end

@implementation NumberInputView

- (instancetype)init {
    if(self == [super init]){
        _maxCount = 10000;
        _minCount = 1;
        [self initView];
    }
    return self;
}

- (int)getCurrentCount {
    int result = 0;
    if (_inputTextField.text.length > 0) {
        result = _inputTextField.text.intValue;
    }
    return result;
}

- (void)initView {
    _leftButton = [[UIButton alloc]init];
    [_leftButton setTitle:@"-" forState:UIControlStateNormal];
    [_leftButton imageLayout:ImageLayoutRight centerPadding:0];
    _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_leftButton setTitleColor:[UIColor hexColor:@"#353648"] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];
    [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.width.height.equalTo(@30);
    }];
    
    _rightButton = [[UIButton alloc]init];
    [_rightButton setTitle:@"+" forState:UIControlStateNormal];
//    [_rightButton imageLayout:ImageLayoutLeft centerPadding:0];
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_rightButton setTitleColor:[UIColor hexColor:@"#353648"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.width.height.equalTo(@30);
    }];
    
    _inputTextField = [[UITextField alloc]init];
    _inputTextField.text = @"1";
    _inputTextField.textColor = [UIColor hexColor:@"#353648"];
    _inputTextField.backgroundColor = [UIColor hexColor:@"#F4F4F6"];
    _inputTextField.textAlignment = NSTextAlignmentCenter;
    _inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_inputTextField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_inputTextField];
    [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftButton.mas_right);
        make.top.bottom.equalTo(_leftButton);
        make.right.equalTo(_rightButton.mas_left);
    }];
}

#pragma mark - button event
- (void)leftBtnClick {
    int currentCount = _inputTextField.text.intValue;
    if (currentCount > _minCount) {
        currentCount -= 1;
    }
    _inputTextField.text = [NSString stringWithFormat:@"%d",currentCount];
    [_inputTextField resignFirstResponder];
}

- (void)rightBtnClick {
    int currentCount = _inputTextField.text.intValue;
    if (currentCount < _maxCount) {
        currentCount += 1;
    }
    _inputTextField.text = [NSString stringWithFormat:@"%d",currentCount];
    [_inputTextField resignFirstResponder];
}

- (void)textDidChange:(UITextField*)textField {
    if (textField.text.length == 0) {
        
    }else {
        if ([RegularOperate isPureNumber:textField.text]) {
            NSUInteger currentCount = _inputTextField.text.intValue;
            currentCount = MAX(MIN(_maxCount, currentCount), _minCount);
            _inputTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)currentCount];
        }else {
//            [LCProgressHUD showMessage:@"存在非数字"];
            _inputTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)_minCount];
        }
    }
}

@end
