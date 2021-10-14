//
//  NSObject+Model.m
//  TreasureChest
//
//  Created by ming on 2020/5/27.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "NSObject+Model.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (Model)

+ (instancetype)initModelWithDictionary:(NSDictionary *)dic{
    
    id myObj = [[self alloc] init];
    unsigned int outCount;     //获取类中的所有成员属性
    objc_property_t *arrPropertys = class_copyPropertyList([self class], &outCount);
    
    for (NSInteger i = 0; i < outCount; i ++) {
        
        //获取属性名字符串
        objc_property_t property = arrPropertys[i];
        //model中的属性名
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        id propertyValue = dic[propertyName];
        if (propertyValue != nil) {
            [myObj setValue:propertyValue forKey:propertyName];
            
        }
        
    }
    //注意在runtime获取属性的时候，并不是ARC Objective-C的对象所有需要释放
    free(arrPropertys);
    return myObj;
}

@end
