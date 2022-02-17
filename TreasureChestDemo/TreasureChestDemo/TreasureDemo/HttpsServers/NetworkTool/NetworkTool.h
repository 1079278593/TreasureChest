//
//  NetworkTool.h
//  Lighting
//
//  Created by imvt on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkTool : NSObject

+ (NSString *)currentSSID;
+ (nullable NSString *)currentBSSID;
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (BOOL)isValidatIP:(NSString *)ipAddress;
+ (NSString*)getIPAddressString;
+ (NSDictionary *)getIPAddressesDict;

+ (void)getHistoryWifiList:(void (^)(NSArray <NSString *> *array))completionHandler;
+ (void)switchHotspotWithSSID:(NSString *)ssid passphrase:(NSString *)passphrase completionHandler:(void (^)(NSError * error))completionHandler;

/**
 * send a dummy GET to "https://8.8.8.8" just to get Network Permission after ios10.0(including)
 */
+ (void) tryOpenNetworkPermission;

@end

NS_ASSUME_NONNULL_END
