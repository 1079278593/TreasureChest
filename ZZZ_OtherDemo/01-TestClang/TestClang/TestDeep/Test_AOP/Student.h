//
//  Student.h
//  TestClang
//
//  Created by ming on 2021/3/30.
//  Copyright © 2021 雏虎科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

-(void)study:(NSString *)subject andRead:(NSString *)bookName;
-(void)study:(NSString *)subject :(NSString *)bookName;

@end

NS_ASSUME_NONNULL_END
