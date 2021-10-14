//
//  NSString+Bundle.h
//  TreasureChest
//
//  Created by jf on 2020/12/28.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Bundle)

+ (NSString *)getBundleShortVersion;
+ (NSString *)getBundleBuildVersion;
+ (NSString *)getBundleVersion;

@end

NS_ASSUME_NONNULL_END


/**
 CFBundleDevelopmentRegion
  
  CFBundleDisplayName  应用名称
  
  CFBundleExecutable
  
  CFBundleExecutablePath
  
  CFBundleIdentifier
  
  CFBundleInfoDictionaryVersion = "6.0";
  
  CFBundleInfoPlistURL
  
  CFBundleName
  
  CFBundlePackageType
  
  CFBundleShortVersionString
  
  CFBundleSignature
  
 CFBundleSupportedPlatforms
 */
