//
//  AutoCoder.m
//  TreasureChest
//
//  Created by ming on 2021/3/31.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "AutoCoder.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation AutoCoder

///解档
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int outCount = 0;
        Ivar *vars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar var = vars[i];
            const char *name = ivar_getName(var);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

///归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int outCount = 0;
    Ivar *vars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar var = vars[i];
        const char *name = ivar_getName(var);
        NSString *key = [NSString stringWithUTF8String:name];

        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}



@end
