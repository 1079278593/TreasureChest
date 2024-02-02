//
//  ICamController.h
//  icam
//
//  Created by chenpz on 16/7/18.
//  Copyright © 2016年 chenpz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICamController;

@protocol ICamControllerDelegate <NSObject>

- (void)iCamControllerDidConnectedClent;
- (void)iCamControllerDidDisconnectedClent;

@end

@interface ICamController : NSObject

@property (nonatomic, weak) id<ICamControllerDelegate> delegate;

- (void)resume;
- (void)pause;

- (void)startLiveStream;
- (void)stopLiveStream;

@end
