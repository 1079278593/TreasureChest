//
//  DeviceMacro.h
//  TreasureChest
//
//  Created by xiao ming on 2019/12/5.
//  Copyright © 2019 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DeviceMacro_h
#define DeviceMacro_h

#define KScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define KScreenWidth  ([[UIScreen mainScreen] bounds].size.width)
#define KStatuBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)

//degree
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


#endif /* DeviceMacro_h */
