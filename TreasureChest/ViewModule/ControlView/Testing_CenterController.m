//
//  Testing_CenterController.m
//  amonitor
//
//  Created by imvt on 2021/10/14.
//  Copyright © 2021 Imagine Vision. All rights reserved.
//

#import "Testing_CenterController.h"
#import "TestingUniform.h"
#import "TestingCenterModel.h"

@interface Testing_CenterController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, weak)IBOutlet UIButton *backButton;
@property(nonatomic, weak)IBOutlet UITableView *tableView;

@property(nonatomic, strong)NSArray <TestingCenterModel *> *collectionViewdatas;

@end

@implementation Testing_CenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubview];
}

#pragma mark - < event >
- (IBAction)backButtonEvent:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - < tableView delegate >
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.collectionViewdatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.collectionViewdatas objectAtIndex:section].datas.count;
    return count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerID = @"headerID";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerID];

    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc]init];
    }
    
    headerView.textLabel.text = [self.collectionViewdatas objectAtIndex:section].sectionTitle;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    }
    
    TestingCenterCellModel *cellModel = [[self.collectionViewdatas objectAtIndex:indexPath.section].datas objectAtIndex:indexPath.row];
    cell.textLabel.text = cellModel.title;

    return cell;
}

///全部用xib形式，否则，增加字段来确定初始化方式。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TestingCenterCellModel *model = [[self.collectionViewdatas objectAtIndex:indexPath.section].datas objectAtIndex:indexPath.row];
    NSString *target = model.target;
    Class NameClass = NSClassFromString(target);
    switch (model.showType) {
        case TestingShowDetailTypePresent:
        {
            UIViewController *controller = [[NameClass alloc]init];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case TestingShowDetailTypeAddToWindow:
        {
//            UIView *view = [[NameClass alloc]init];
            UIView *view = [[[NSBundle mainBundle] loadNibNamed:target owner:self options:nil] lastObject];
            view.frame = CGRectMake((KScreenWidth - model.width)/2.0, (KScreenHeight - model.height)/2.0, model.width, model.height);
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            if (model.isHideCenter) {
                [self backButtonEvent:nil];
            }
        }
            break;
        case TestingShowDetailTypeBeWindow:
        {
            
        }
            break;
        case TestingShowDetailTypePush:
        {
            
        }
            break;
        case TestingShowDetailTypeShare:
        {
            [self showShareController];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - < show detail >

- (void)showShareController {
    NSString *logPath = [TestingUniform systemLogPath];
    //分享的url：本地文件
    NSURL *urlToShare = [NSURL fileURLWithPath:logPath];

    NSArray *activityItems = @[urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToWeibo];
    
    if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPhone) {//if iPhone
        [self presentViewController:activityVC animated:YES completion:nil];
    } else{//if iPad
        UIPopoverController *popup = [[UIPopoverController alloc]initWithContentViewController:activityVC];
        [popup presentPopoverFromRect:CGRectMake(0, 0, 400, 200) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

    //分享之后的回调
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            NSLog(@"completed");
            //分享 成功
        } else  {
            NSLog(@"cancled");
            //分享 取消
        }
    };
}

#pragma mark - < init >
- (void)setupSubview {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionViewdatas = [TestingCenterModel generateDatas];
}

@end
