//
//  Student.m
//  TestClang
//
//  Created by ming on 2021/3/30.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import "Student.h"

@implementation Student

-(void)study:(NSString *)subject andRead:(NSString *)bookName
{
    NSLog(@"Invorking method on %@ object with selector %@",[self class],NSStringFromSelector(_cmd));
}

-(void)study:(NSString *)subject :(NSString *)bookName
{
    NSLog(@"Invorking method on %@ object with selector %@",[self class],NSStringFromSelector(_cmd));
}

@end
