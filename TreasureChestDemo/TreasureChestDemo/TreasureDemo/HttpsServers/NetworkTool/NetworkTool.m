//
//  NetworkTool.m
//  Lighting
//
//  Created by imvt on 2021/11/25.
//

#import "NetworkTool.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation NetworkTool

//这个要想获取到数据，需要名字4个条件的一个，具体看CNCopyCurrentNetworkInfo的文档。
//这里最好的方式是调用switchHotspotWithSSID()函数就可以了。场景就是：app内切换wifi
+ (NSString *)currentSSID {
    NSString *ssid = @" ";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
        }
    }
    return ssid;
}

+ (nullable NSString *)currentBSSID {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    // Key: BSSID, SSID, SSIDDATA
    return [(NSDictionary*)info objectForKey:@"BSSID"];
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddressesDict];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        //筛选出IP地址格式
        if([self isValidatIP:address]) *stop = YES;
    } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"NetworkTool isValidatIP 输出结果：%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSString*)getIPAddressString {
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    int error;
    error = getifaddrs(&addrs);
    NSString *hostname = nil;
    
    if (error)
    {
        NSLog(@"%s", gai_strerror(error));
    }
    for (cursor = addrs; cursor; cursor = cursor->ifa_next)
    {
        if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
        {
            NSString *ifa_name = [NSString stringWithUTF8String:cursor->ifa_name];
            if([@"en0" isEqualToString:ifa_name] ||
               [@"en1" isEqualToString:ifa_name])
            {
                hostname = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                break;
            }
        }
    }
    freeifaddrs(addrs);
    return hostname;
}

//与getIPAddressString有点重复
+ (NSDictionary *)getIPAddressesDict {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

#pragma mark - < wifi >
+ (void)getHistoryWifiList:(void (^)(NSArray <NSString *> *array))completionHandler {
    [[NEHotspotConfigurationManager sharedManager] getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * array) {
        completionHandler(array);
    }];
}

+ (void)switchHotspotWithSSID:(NSString *)ssid passphrase:(NSString *)passphrase completionHandler:(void (^)(NSError * error))completionHandler {
    [[NEHotspotConfigurationManager sharedManager] applyConfiguration:[[NEHotspotConfiguration alloc] initWithSSID:ssid passphrase:passphrase isWEP:NO] completionHandler:^(NSError *error) {
        completionHandler(error);
    }];
}

#pragma mark - < <#expression#> >
+ (void)tryOpenNetworkPermission {
    // only ios 10.0 later required to try open network permission
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        NSURL *url = [NSURL URLWithString:@"https://8.8.8.8"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:1000];
        
        
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[self DEFAULT_SESSION_CONFIGURATION] delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
        [[urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        }] resume];
    }
}

+ (NSURLSessionConfiguration *)DEFAULT_SESSION_CONFIGURATION {
    static dispatch_once_t predicate;
    static NSURLSessionConfiguration *DEFAULT_SESSION_CONFIGURATION;
    dispatch_once(&predicate, ^{
        DEFAULT_SESSION_CONFIGURATION = [NSURLSessionConfiguration defaultSessionConfiguration];
    });
    return DEFAULT_SESSION_CONFIGURATION;
}

@end
