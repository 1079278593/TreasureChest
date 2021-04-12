//
//  ColorMacro.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/17.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#ifndef ColorMacro_h
#define ColorMacro_h

#define KRandomColor(a) [UIColor colorWithRed:(arc4random() % 256)/255.0 green:(arc4random() % 256)/255.0 blue:(arc4random() % 256)/255.0 alpha:a]

#define KBackgroundColor  [UIColor hexColor:@"#FCFCFC"]
#define KTextMainColor  [UIColor hexColor:@"#353648"]
#define KTextSecondColor  [UIColor hexColor:@"#757685"]
#define KLineColor  [UIColor hexColor:@"#D8D8D8"]

#endif /* ColorMacro_h */
