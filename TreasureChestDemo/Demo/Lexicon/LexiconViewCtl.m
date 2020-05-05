//
//  LexiconViewCtl.m
//  TreasureChest
//
//  Created by ming on 2020/5/5.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "LexiconViewCtl.h"
#import "LexiconFileModel.h"

@interface LexiconViewCtl ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray <LexiconFileModel*> *datas;

@end

@implementation LexiconViewCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datas = [NSMutableArray arrayWithArray:[self getCatalogue]];
    self.tableView.frame = CGRectMake(0, 64, KScreenWidth, 400);
    
}

#pragma mark - < delegate >
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentify = [NSString stringWithFormat:@"cellIdentify"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = self.datas[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //将txt转plist
    NSString *path = [[NSBundle mainBundle]pathForResource:self.datas[indexPath.row].fileName ofType:@"txt"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //这里有可能是：\r或者\n,或者：\r\n，或者其它带空格的。
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    for (NSString *word in arr) {
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:[word componentsSeparatedByString:@"\t"]];
        NSDictionary *dict;
        if (tmp.count == 2) {
            dict = @{@"words":tmp[0],@"frequency":tmp[1]};
        }
        if (tmp.count == 1) {
            dict = @{@"words":tmp[0]};
        }
        NSLog(@"%@",dict);
        [result addObject:dict];
    }
    [self generatePlistToSandBox:result plistName:self.datas[indexPath.row].fileName];
}

#pragma mark - < init >
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - < private >
- (NSArray *)getCatalogue {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Lexicon" ofType:@"plist"];
    NSArray *arr = [LexiconFileModel mj_objectArrayWithFile:path];
    return arr;
}

//生成plist后，自己到对应沙盒位置提取文件。
//dict可以是NSArray或者NSDictionary等。
//实际txt会比plist占用空间小：七八倍。
- (void)generatePlistToSandBox:(id)dict plistName:(NSString *)plistName {
    plistName = [NSString stringWithFormat:@"%@.plist",plistName];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [path objectAtIndex:0];
    NSLog(@"生成的plist文件path：%@",documentsPath);
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:plistName];
    [dict writeToFile:plistPath atomically:YES];
}

@end
