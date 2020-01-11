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
@property(strong, nonatomic)UITextView *dictShowTextView;

@end

@implementation DictionaryMainCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _datas = [NSMutableArray arrayWithCapacity:0];
    [self initView];
    [FMDictManager sharedManager];
    [FMDBManager sharedManager];
    
    [self bindModel];
}

- (void)bindModel {
    @weakify(self);
    [[RACObserve([FMDictManager sharedManager], results) ignore:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if ([FMDictManager sharedManager].results.count > 0) {
            NSDictionary *dic = [FMDictManager sharedManager].results[0];
            self.dictShowTextView.text = [NSString stringWithFormat:@"%@",dic];
        }
        
    }];
}

- (void)initView {
    
    _textField = [[UITextField alloc]init];
    _textField.placeholder = @"输入关键词";
    _textField.layer.borderWidth = 1;
    _textField.frame = CGRectMake(20, 65, KScreenWidth-40, 44);
    [_textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_textField];
    
    
    self.tableView.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.3];
    self.tableView.frame = CGRectMake(0, 110, KScreenWidth, KScreenHeight);
    
    _dictShowTextView = [[UITextView alloc]init];
    _dictShowTextView.layer.borderWidth = 1;
    _dictShowTextView.frame = CGRectMake(0, 110, KScreenWidth, KScreenHeight);
    [self.view addSubview:_dictShowTextView];
    
}

- (void)textDidChange:(UITextField *)textField {
    [[FMDictManager sharedManager]requestWithKeywords:textField.text];
//    [[FMDictManager sharedManager]requestWithTranslation:textField.text];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [[FMDictManager sharedManager]requestTotalCount];
    [[FMDBManager sharedManager]startCopy];
}

#pragma mark - < table >
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.rowHeight = 45;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = _datas[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end

