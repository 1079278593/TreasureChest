//
//  DictionaryMainCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "DictionaryMainCtl.h"
#import "FMDictManager.h"
#import "DictionaryMainCell.h"

@interface DictionaryMainCtl ()<UITableViewDelegate,UITableViewDataSource>

@property(strong, nonatomic)FMDBManager *ftsDictManager;
@property(strong, nonatomic)FMDictManager *dictQueryManager;
@property(strong, nonatomic)NSMutableArray *datas;

@property(strong, nonatomic)UITextField *textField;
@property(strong, nonatomic)UITableView *tableView;
@property(strong, nonatomic)UILabel *totalCountLabel;

@end

@implementation DictionaryMainCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _datas = [NSMutableArray arrayWithCapacity:0];
    [self initView];
    self.dictQueryManager = [FMDictManager sharedManager];
    self.ftsDictManager = [FMDBManager sharedManager];
    
    [self bindModel];
}

- (void)bindModel {
    @weakify(self);
    [[RACObserve(self.dictQueryManager, datas) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.datas = self.dictQueryManager.datas;
        [self.tableView reloadData];
        self.totalCountLabel.text = [NSString stringWithFormat:@"当前搜索结果：%lu个。(带空格可以搜索更多)",(unsigned long)self.datas.count];
    }];
}

- (void)initView {
    
    _textField = [[UITextField alloc]init];
    _textField.placeholder = @"输入关键词";
    _textField.keyboardType = UIKeyboardTypeASCIICapable;
    _textField.frame = CGRectMake(15, 65, KScreenWidth-40, 44);
    [_textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_textField];
    
    UIView *breakLine = [[UIView alloc]init];
    breakLine.backgroundColor = [UIColor lightGrayColor];;
    [self.view addSubview:breakLine];
    [breakLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_textField);
        make.top.equalTo(_textField.mas_bottom).offset(-2);
        make.right.equalTo(_textField);
        make.height.equalTo(@0.5);
    }];

    _totalCountLabel = [[UILabel alloc]init];
    _totalCountLabel.text = @"当前搜索结果：";
    _totalCountLabel.textAlignment = NSTextAlignmentLeft;
    _totalCountLabel.font = [UIFont systemFontOfSize:14];
    _totalCountLabel.textColor = KTextMainColor;
    [self.view addSubview:_totalCountLabel];
    [_totalCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(breakLine);
        make.right.equalTo(breakLine);
        make.top.equalTo(breakLine).offset(5);
        make.height.equalTo(@20);
    }];
    
    UIView *breakLine1 = [[UIView alloc]init];
    breakLine1.backgroundColor = [UIColor lightGrayColor];;
    [self.view addSubview:breakLine1];
    [breakLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_totalCountLabel);
        make.top.equalTo(_totalCountLabel.mas_bottom).offset(1);
        make.right.equalTo(_totalCountLabel);
        make.height.equalTo(@0.5);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(breakLine1.mas_bottom).offset(1);
        make.bottom.equalTo(self.view);
    }];
}

- (void)textDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self.dictQueryManager requestWithKeywords:textField.text];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.dictQueryManager requestTotalCount];
//    [self.ftsDictManager startCopy];
}

#pragma mark - < table >do
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.rowHeight = 55;
        [_tableView registerClass:[DictionaryMainCell class] forCellReuseIdentifier:NSStringFromClass([DictionaryMainCell class])];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DictionaryMainCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DictionaryMainCell class])];
    cell.model = _datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:true];
}

@end

