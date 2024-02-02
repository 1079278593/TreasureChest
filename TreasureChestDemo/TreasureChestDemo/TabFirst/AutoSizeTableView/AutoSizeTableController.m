//
//  AutoSizeTableController.m
//  TreasureChest
//
//  Created by ming on 2020/11/1.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "AutoSizeTableController.h"
#import <SDAutoLayout/SDAutoLayout.h>
#import "UITableView+SDAutoTableViewCellHeight.h"
#import "AutoSizeCell.h"
#import "AutoSizeModel.h"

@interface AutoSizeTableController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)NSMutableArray *modelsArray;
@property(nonatomic, strong)UITableView *tableView;
@end

@implementation AutoSizeTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatModelsWithCount:10];
    [self setupSubviews];
}

#pragma mark - < delegate >
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"test";
    AutoSizeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[AutoSizeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.model = self.modelsArray[indexPath.row];
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    
    ///////////////////////////////////////////////////////////////////////
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤2 * >>>>>>>>>>>>>>>>>>>>>>>>
    /* model 为模型实例， keyPath 为 model 的属性名，通过 kvc 统一赋值接口 */
    CGFloat height = [self.tableView cellHeightForIndexPath:indexPath model:self.modelsArray[indexPath.row] keyPath:@"model" cellClass:[AutoSizeCell class] contentViewWidth:KScreenWidth];
    NSLog(@"cell height ;%f",height);
    return height;
}
#pragma mark - < init view >
- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = false;
        _tableView.alwaysBounceVertical = true;
    }
    return _tableView;
}

- (void)creatModelsWithCount:(NSInteger)count
{
    if (!_modelsArray) {
        _modelsArray = [NSMutableArray new];
    }
    
    NSArray *iconImageNamesArray = @[@"icon0.jpg",
                                     @"icon1.jpg",
                                     @"icon2.jpg",
                                     @"icon3.jpg",
                                     @"icon4.jpg",
                                     ];
    
    NSArray *namesArray = @[@"GSD_iOS",
                            @"风口上的猪",
                            @"当今世界网名都不好起了",
                            @"我叫郭德纲",
                            @"Hello Kitty"];
    
    NSArray *textArray = @[@"当你的 app 没有提供 3x 的 LaunchImage 时，系统默认进入兼容模式，大屏幕一切按照 320 宽度渲染，屏幕宽度返回 320；然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。",
                           @"然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。",
                           @"当你的 app 没有提供 3x 的 LaunchImage 时",
                           @"但是建议不要长期处于这种模式下，否则在大屏上会显得字大，内容少，容易遭到用户投诉。",
                           @"屏幕宽度返回 320；然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。但是建议不要长期处于这种模式下。"
                           ];
    
    NSArray *picImageNamesArray = @[ @"pic0.jpg",
                                     @"pic1.jpg",
                                     @"pic2.jpg",
                                     @"pic3.jpg",
                                     @"pic4.jpg",
                                     ];
    
    for (int i = 0; i < count; i++) {
        int iconRandomIndex = arc4random_uniform(5);
        int nameRandomIndex = arc4random_uniform(5);
        int contentRandomIndex = arc4random_uniform(5);
        int picRandomIndex = arc4random_uniform(5);
        
        AutoSizeModel *model = [AutoSizeModel new];
        model.iconName = iconImageNamesArray[iconRandomIndex];
        model.name = namesArray[nameRandomIndex];
        model.content = textArray[contentRandomIndex];
        
        
        // 模拟“有或者无图片”
        int random = arc4random_uniform(100);
        if (random <= 80) {
            model.picName = picImageNamesArray[picRandomIndex];
        }
        
        [self.modelsArray addObject:model];
    }
}

@end
