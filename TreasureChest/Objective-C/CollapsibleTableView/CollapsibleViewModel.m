//
//  CollapsibleViewModel.m
//  TreasureChest
//
//  Created by xiao ming on 2019/12/19.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import "CollapsibleViewModel.h"
#import "MJExtension.h"

@implementation CollapsibleViewModel

- (instancetype)init {
    if(self == [super init]){
        [self requestData];
    }
    return self;
}

- (void)requestData {
   NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TestData" ofType:@"plist"];
    NSArray *date = [NSArray arrayWithContentsOfFile:filePath];
    self.datas = [CollapsibleModel mj_objectArrayWithKeyValuesArray:date];
}

@end
