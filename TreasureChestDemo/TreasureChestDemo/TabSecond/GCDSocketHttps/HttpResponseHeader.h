//
//  HttpResponseHeader.h
//  AwesomeCamera
//
//  Created by imvt on 2024/1/20.
//  Copyright © 2024 ImagineVision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpResponseHeader: NSObject

@property(nonatomic, assign)int statusCode;

@property(nonatomic, strong)NSString *location; //!< 302时才会出现，重定向的url
@property(nonatomic, assign)NSUInteger contentLength;
@property(nonatomic, strong)NSString *cookie;   //!< 这里是临时，收到时保存了一份到沙盒。
@property(nonatomic, strong)NSString *www_authenticate; //!< 保存头部分返回的数据

@end

NS_ASSUME_NONNULL_END
