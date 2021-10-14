//
//  Testing_ControlView.m
//  amonitor
//
//  Created by imvt on 2021/10/13.
//  Copyright © 2021 Imagine Vision. All rights reserved.
//

#import "Testing_ControlView.h"
#import "TestingUniform.h"

@interface Testing_ControlView () <UITextFieldDelegate>

@property(nonatomic, weak)IBOutlet UITextView *logTextView;
@property(nonatomic, weak)IBOutlet UITextField *commandTextField;
@property(nonatomic, weak)IBOutlet UIButton *confirmBtn;

@property(nonatomic, weak)IBOutlet UIButton *localIpBtn;
@property(nonatomic, weak)IBOutlet UIButton *networkIpBtn;
@property(nonatomic, weak)IBOutlet UIButton *clearLogBtn;
@property(nonatomic, weak)IBOutlet UITextField *filterTextField;

@property(nonatomic, weak)IBOutlet UIButton *startCameraBtn;
@property(nonatomic, weak)IBOutlet UIButton *stopCameraBtn;
@property(nonatomic, weak)IBOutlet UIButton *restartCameraBtn;
@property(nonatomic, weak)IBOutlet UIButton *clearCameraBtn;

@property(nonatomic, weak)IBOutlet UIButton *startStreamBtn;
@property(nonatomic, weak)IBOutlet UIButton *stopStreamBtn;
@property(nonatomic, weak)IBOutlet UIButton *restartStreamBtn;
@property(nonatomic, weak)IBOutlet UIButton *clearStreamBtn;

@property(nonatomic, strong)NSString *logPath;
@property(nonatomic, strong)NSMutableArray *logLines;       //!< 所有输出按行分割
@property(nonatomic, strong)NSMutableArray *keywordsLines;  //!< 含有关键词的‘行’
@property(nonatomic, strong)NSString *keywords;      //!< 当前关注的词。找到每一行中包含这个关键词的行。
@property(nonatomic, assign)int currentLine;

@end

@implementation Testing_ControlView

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
    [self addGestureRecognizer:pinchGesture];
    
    [self setupSubview];
    [self redirectLog];
    [self startTiemr];
}

#pragma mark - < event >
-(void)tapGesture:(UITapGestureRecognizer *)tapGesture{
    [self endEditing:YES];
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    CGFloat minX = KScreenWidth - self.width;   //frame里x的最小值
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint tmp = [gesture translationInView:self];
        CGFloat newX = self.x + tmp.x;
        CGFloat newY = self.y + tmp.y;
//        newX = MAX(minX, newX);
        self.x = newX;
        self.y = newY;
        [gesture setTranslation:CGPointZero inView:self];
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformScale(self.transform, gesture.scale, gesture.scale);
        [gesture setScale:1];
    }
}

- (IBAction)backButtonEvent:(UIButton *)button {
    [self removeFromSuperview];
}

- (IBAction)confirmButtonEvent:(UIButton *)button {
    
}

- (IBAction)localIPButtonEvent:(UIButton *)button {
    
}

- (IBAction)networkIPButtonEvent:(UIButton *)button {
    
}

- (IBAction)cleanLogButtonEvent:(UIButton *)button {
    [self redirectLog];//清除
    self.currentLine = 0;
}

- (IBAction)startCameraButtonEvent:(UIButton *)button {
    
}

- (IBAction)stopCameraButtonEvent:(UIButton *)button {
    
}

- (IBAction)restartCameraButtonEvent:(UIButton *)button {
    
}

- (IBAction)clearCameraButtonEvent:(UIButton *)button {
    
}

- (IBAction)startStreamButtonEvent:(UIButton *)button {
    
}

- (IBAction)stopStreamButtonEvent:(UIButton *)button {
    
}

- (IBAction)restartStreamButtonEvent:(UIButton *)button {
    
}

- (IBAction)clearStreamButtonEvent:(UIButton *)button {
    
}

#pragma mark - < text delegate >
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![self.keywords isEqualToString:textField.text]) {
        //关键词不同，需要重新获取‘包含关键词’的‘行’
        [self getKeywordsLines:textField.text];
        self.keywords = textField.text;
    }
}

#pragma mark - < timer >
- (void)startTiemr {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(readLog) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    
}

- (void)readLog {
    NSData *data = [NSData dataWithContentsOfFile:self.logPath];
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    //这里就开始处理成数组。
    
    self.logTextView.text = result;
    [_logTextView scrollRangeToVisible:NSMakeRange(_logTextView.text.length, 1)];
}

#pragma mark - < filter >
- (NSMutableArray *)getKeywordsLines:(NSString *)keywords {
    NSString *text;
    if ([self.keywords isEqualToString:keywords]) {
        //从index开始截取，然后‘分割’
//        text =
        [text componentsSeparatedByString:@"\n"];
    }else {
        text = self.logTextView.text;
        [text componentsSeparatedByString:@"\n"];
    }
    
    return nil;
}

#pragma mark - < private >
- (void)redirectLog {
    NSFileManager *defaulManager = [NSFileManager defaultManager];
    [defaulManager removeItemAtPath:self.logPath error:nil];
    
    // 重定向输入输出流
    freopen([self.logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([self.logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

#pragma mark - < init view >
- (void)setupSubview {
    self.confirmBtn.layer.borderWidth = 1;
}

- (NSString *)logPath {
    if (_logPath == nil) {
        _logPath = [TestingUniform systemLogPath];
    }
    return _logPath;
}

@end
