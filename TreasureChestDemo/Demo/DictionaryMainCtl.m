//
//  DictionaryMainCtl.m
//  TreasureChest
//
//  Created by xiao ming on 2020/1/8.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "DictionaryMainCtl.h"
#import "FMDictManager.h"

@interface DictionaryMainCtl ()<UITableViewDelegate,UITableViewDataSource>

@property(strong, nonatomic)NSMutableArray *datas;
@property(strong, nonatomic)UITableView *tableView;
@property(strong, nonatomic)UITextField *textField;

@property(strong, nonatomic)FMDBManager *ftsDictManager;
@property(strong, nonatomic)FMDictManager *dictQueryManager;

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
    [[RACObserve(self.dictQueryManager, results) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.datas = self.dictQueryManager.results;
        [self.tableView reloadData];
    }];
}

- (void)initView {
    
    _textField = [[UITextField alloc]init];
    _textField.placeholder = @"输入关键词";
    _textField.frame = CGRectMake(20, 65, KScreenWidth-40, 44);
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
    
    self.tableView.frame = CGRectMake(0, 110, KScreenWidth, 350);

}

- (void)textDidChange:(UITextField *)textField {
    if (textField.text.length > 1) {
        [self.dictQueryManager requestWithKeywords:textField.text];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.dictQueryManager requestTotalCount];
    [self.ftsDictManager startCopy];
}

#pragma mark - < table >
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.rowHeight = 300;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",_datas[indexPath.row]];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.layer.borderWidth = 1;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
//    cell.textLabel.text = @"dsaf";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end

