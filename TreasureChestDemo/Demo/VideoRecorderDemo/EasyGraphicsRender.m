//
//  EasyGraphicsRender.m
//  TreasureChest
//
//  Created by xiao ming on 2020/4/11.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import "EasyGraphicsRender.h"
#import <UIKit/UIGraphicsRendererSubclass.h>

@implementation EasyGraphicsRender

+ (CGContextRef)contextWithFormat:(UIGraphicsRendererFormat *)format {
    
    return [super contextWithFormat:format];
}

+ (Class)rendererContextClass {
    return [super rendererContextClass];
}


//绘制UIImage
+ (UIImage*)resizeImage:(UIImage*)image size:(CGSize)size {
    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc]initWithSize:size];
    return [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

//绘制PDF
- (void)drawPDF {
    
    UIGraphicsPDFRenderer *renderer = [[UIGraphicsPDFRenderer alloc] initWithBounds:CGRectMake(0, 0, 500, 300)];

    //1.
    /**
     NSData *pdf = [renderer PDFDataWithActions:^(UIGraphicsPDFRendererContext * _Nonnull context) {
         NSDictionary *attributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:150]};
         for (int page = 1; page < 4; page++) {
             [context beginPage];
             NSString *text = [NSString stringWithFormat:@"Page %d", page];
             [text drawInRect:CGRectMake(0, 0, 500, 200) withAttributes:attributes];
         }
     }];
     */
    
    //2.
    NSData *pdf = [renderer PDFDataWithActions:^(UIGraphicsPDFRendererContext * _Nonnull context) {
      NSDictionary *attributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:150]};
        
      NSString *nextPage = @"Next Page ↠";
      CGRect nextPageRect = CGRectMake(350, 250, 150, 40);
      NSDictionary *nextPageAttributes = @{
        NSFontAttributeName : [UIFont systemFontOfSize:25],
        NSBackgroundColorAttributeName : [UIColor redColor],
        NSForegroundColorAttributeName : [UIColor whiteColor]
      };
      for (int page = 1; page < 4; page++) {
        [context beginPage];
        NSString *pageNumber = [NSString stringWithFormat:@"Page %d", page];
        [pageNumber drawInRect:CGRectMake(0, 0, 500, 200) withAttributes:attributes];
        [nextPage drawInRect:nextPageRect withAttributes:nextPageAttributes];
          
        [context addDestinationWithName:[NSString stringWithFormat:@"page-%d", page]
                                atPoint:CGContextConvertPointToDeviceSpace(context.CGContext, CGPointZero)];
        [context setDestinationWithName:[NSString stringWithFormat:@"page-%d", page+1]
                                forRect:CGContextConvertRectToDeviceSpace(context.CGContext, nextPageRect)];
      }
    }];
}
@end
