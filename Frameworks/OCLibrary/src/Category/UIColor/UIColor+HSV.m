//
//  UIColor+HSV.m
//  Poppy_Dev01
//
//  Created by xiao ming on 2020/7/24.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "UIColor+HSV.h"

@implementation UIColor (HSV)

- (void)ColorToHSV:(CGFloat *)hue s:(CGFloat *)saturation v:(CGFloat *)brightness {

    const CGFloat *components = CGColorGetComponents(self.CGColor);

    //0~1
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];

    CGFloat minRGB = MIN(red, MIN(green,blue));
    CGFloat maxRGB = MAX(red, MAX(green,blue));

    if (minRGB==maxRGB) {
        *hue = 0;
        *saturation = 0;
        *brightness = minRGB;
    } else {
        CGFloat d = (red==minRGB) ? green-blue : ((blue==minRGB) ? red-green : blue-red);
        CGFloat h = (red==minRGB) ? 3 : ((blue==minRGB) ? 1 : 5);
        *hue = (h - d/(maxRGB - minRGB)) / 6.0;
        *saturation = (maxRGB - minRGB)/maxRGB;
        *brightness = maxRGB;
    }
//    NSLog(@"hue: %0.2f, saturation: %0.2f, value: %0.2f", *hue, *saturation, *brightness);
}

/**
 CGFloat r, g, b, a, h, s, v;
  
 const CGFloat *comp = CGColorGetComponents([myUIColor CGColor]);
  
 r = comp[0];
 g = comp[1];
 b = comp[2];
 a = comp[3];
  
 RGBtoHSV(r, g, b, &h, &s, &v);
 
 */
static void RGBtoHSV1( float r, float g, float b, float *h, float *s, float *v )
{
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;

}

@end
