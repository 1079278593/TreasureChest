//
//  CameraStatusLoop.h
//  AwesomeCamera
//
//  Created by imvt on 2024/2/2.
//  Copyright © 2024 ImagineVision. All rights reserved.
//  不建议单例？（感觉单例也OK，看情况)（可能拓展是个问题，协议？）

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SessionLoopStatus) {
    SessionLoopStatus_Idle = 0,             //!< 初始状态
    SessionLoopStatus_TryConnecting,        //!< 尝试连接（端口80或者443
    SessionLoopStatus_SocketConnected,      //!< socket成功连接
    SessionLoopStatus_KeepLive,             //!< keep live
//    SessionLoopStatus_NetworkChange,        //!< wifi变化
    SessionLoopStatus_SocketDisconnect,     //!< socket断开连接
    
};

@protocol CameraStatusLoopDelegate <NSObject>

- (void)cameraStatusLoop:(SessionLoopStatus)status connectedDict:(NSDictionary *)dict;
- (void)networkChange:(NSString *)newSSIDName;

@end

@interface CameraStatusLoop : NSObject

@property(nonatomic, weak)id<CameraStatusLoopDelegate> delegate;

- (void)startLoop;
- (void)stopLoop;

///传入所有要尝试的host，内部会尝试80和443，看看哪个host的哪个端口可行
- (void)checkHosts:(NSArray *)hosts;

@end

NS_ASSUME_NONNULL_END
