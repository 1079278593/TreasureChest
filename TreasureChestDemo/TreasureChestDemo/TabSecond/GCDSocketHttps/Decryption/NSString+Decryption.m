//
//  NSString+Decryption.m
//  Lighting
//
//  Created by imvt on 2023/12/15.
//

#import "NSString+Decryption.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Decryption)

+ (NSString *)md5WithSalt:(NSString *)salt {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    int value = (int)timeInterval % (24*3600);
    value = (int)timeInterval - value;//这一天的早上8点的时间戳。
    NSString *result = [NSString stringWithFormat:@"%d%@",value,salt];
    NSString *code = [self md5ToString:result];
    return code;
}

+ (NSString *)md5ToString:(NSString *)target {
    const char *cStr = [target UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr),digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

@end
