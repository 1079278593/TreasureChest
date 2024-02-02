//
//  NSString+Decryption.h
//  Lighting
//
//  Created by imvt on 2023/12/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Decryption)

+ (NSString *)md5WithSalt:(NSString *)salt;

+ (NSString *)md5ToString:(NSString *)target;

@end

NS_ASSUME_NONNULL_END
