//
//  QiKeychainPasswordItem.m
//  QiKeychain
//
//  Created by wangyongwang on 2019/1/29.
//  Copyright © 2019年 QiShare. All rights reserved.
//

#import "QiKeychainItem.h"
#import <Security/SecItem.h>
#import <Security/SecBase.h>

NSString* const Account = @"MemoryKing";
NSString* const KeychainService = @"com.ming.dayMemory.ios.keychain";
static NSString* const keychainErrorDomain = @"com.ming.dayMemory.ios.keychain.errorDomain";
static NSInteger const kErrorCodeKeychainSomeArgumentsInvalid = 1000; //! 传入的部分参数无效

@implementation QiKeychainItem

+ (NSError *)updateKeychainWithService:(NSString *)service account:(NSString *)account password:(NSString *)password {
    
    if (!account || !password || !service) {
        NSError *error = [self errorWithErrorCode:kErrorCodeKeychainSomeArgumentsInvalid];
        return error;
    }
    NSDictionary *queryItems = @{(id)kSecClass: (id)kSecClassGenericPassword,
                               (id)kSecAttrService: service,
                               (id)kSecAttrAccount: account
                               };
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *updatedItems = @{
                                   (id)kSecValueData: passwordData,
                                   };
    OSStatus updateStatus = SecItemUpdate((CFDictionaryRef)queryItems, (CFDictionaryRef)updatedItems);
    return [self errorWithErrorCode:updateStatus];
}

+ (NSError *)deleteWithService:(NSString *)service account:(NSString *)account {
    
    if (!service || !account) {
        return [self errorWithErrorCode:kErrorCodeKeychainSomeArgumentsInvalid];
    }
    NSDictionary *deleteSecItems = @{
                                    (id)kSecClass: (id)kSecClassGenericPassword,
                                    (id)kSecAttrService: service,
                                    (id)kSecAttrAccount: account
                                    };
    OSStatus errorCode = SecItemDelete((CFDictionaryRef)deleteSecItems);
    return [self errorWithErrorCode:errorCode];
}

+ (NSError *)queryKeychainWithService:(NSString *)service account:(NSString *)account {
    
    if (!service || !account) {
        return [self errorWithErrorCode:kErrorCodeKeychainSomeArgumentsInvalid];
    }
    NSDictionary *matchSecItems = @{
                                    (id)kSecClass: (id)kSecClassGenericPassword,
                                    (id)kSecAttrService: service,
                                    (id)kSecAttrAccount: account,
                                    (id)kSecMatchLimit: (id)kSecMatchLimitOne,
                                    (id)kSecReturnData: @(YES)
                                    };
    CFTypeRef dataRef = nil;
    OSStatus errorCode = SecItemCopyMatching((CFDictionaryRef)matchSecItems, (CFTypeRef *)&dataRef);
    if (errorCode == errSecSuccess) {
        NSString *password = [[NSString alloc] initWithData:CFBridgingRelease(dataRef) encoding:NSUTF8StringEncoding];
        return [self errorWithErrorCode:errSecSuccess errorMessage:password];
    }
    return [self errorWithErrorCode:errorCode];
}

+ (NSError *)saveKeychainWithService:(NSString *)service account:(NSString *)account password:(NSString *)password {
    
    if (!account || !password || !service) {
        NSError *error = [self errorWithErrorCode:kErrorCodeKeychainSomeArgumentsInvalid];
        return error;
    }
    
    NSError *queryError = [self queryKeychainWithService:service account:account];
    if (queryError.code == errSecSuccess) {
        // update
        return [self updateKeychainWithService:service account:account password:password];
    }
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    // save
    NSDictionary *saveSecItems = @{(id)kSecClass: (id)kSecClassGenericPassword,
                                   (id)kSecAttrService: service,
                                   (id)kSecAttrAccount: account,
                                   (id)kSecValueData: passwordData
                               };
    OSStatus saveStatus = SecItemAdd((CFDictionaryRef)saveSecItems, NULL);
    return [self errorWithErrorCode:saveStatus];
}

+ (NSError *)errorWithErrorCode:(OSStatus)errorCode {
    
    NSString *errorMsg = nil;
    
    switch (errorCode) {
        case errSecSuccess: {
            return nil;
            break;
        }
        case kErrorCodeKeychainSomeArgumentsInvalid:
            errorMsg = NSLocalizedString(@"参数无效", nil);
            break;
        case errSecDuplicateItem: // -25299
            errorMsg = NSLocalizedString(@"The specified item already exists in the keychain. ", nil);
            break;
        case errSecItemNotFound: // -25300
            errorMsg = NSLocalizedString(@"The specified item could not be found in the keychain. ", nil);
            break;
        default: {
            if (@available(iOS 11.3, *)) {
                errorMsg = (__bridge_transfer NSString *)SecCopyErrorMessageString(errorCode, NULL);
            }
            break;
        }
    }
    NSDictionary *errorUserInfo = nil;
    if (errorMsg) {
        errorUserInfo = @{NSLocalizedDescriptionKey: errorMsg};
    }
    
    return [NSError errorWithDomain:keychainErrorDomain code:kErrorCodeKeychainSomeArgumentsInvalid userInfo:errorUserInfo];
}

+ (NSError *)errorWithErrorCode:(OSStatus)errCode errorMessage:(NSString *)errorMsg {
    
    if (errCode == errSecSuccess && errorMsg) {
        return [NSError errorWithDomain:keychainErrorDomain code:errSecSuccess userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
    } else {
        return [self errorWithErrorCode:errCode];
    }
}

+ (NSString *)uuid{
    NSString *uuid = @"";
    NSError *keychainError = [self queryKeychainWithService:KeychainService account:Account];
    if (keychainError.code == errSecSuccess) {
        uuid = [keychainError.userInfo valueForKey:NSLocalizedDescriptionKey];
    } else {
        uuid = [NSUUID UUID].UUIDString;
        [self saveKeychainWithService:KeychainService account:Account password:uuid];
    }
    return uuid;
}

@end

