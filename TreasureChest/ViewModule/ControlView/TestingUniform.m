//
//  TestingUniform.m
//  amonitor
//
//  Created by imvt on 2021/10/14.
//  Copyright © 2021 Imagine Vision. All rights reserved.
//

#import "TestingUniform.h"

@implementation TestingUniform

+ (NSString *)systemLogPath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"tempForLog.log"];
    NSString *logPath = [document stringByAppendingPathComponent:fileName];
    return logPath;
}

@end
