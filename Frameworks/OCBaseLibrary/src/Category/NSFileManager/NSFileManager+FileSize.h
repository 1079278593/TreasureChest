//
//  NSFileManager+FileSize.h
//  Pods
//
//  Created by imvt on 2023/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (FileSize)

+ (uint64_t)getFreeDiskspace;

@end

NS_ASSUME_NONNULL_END
