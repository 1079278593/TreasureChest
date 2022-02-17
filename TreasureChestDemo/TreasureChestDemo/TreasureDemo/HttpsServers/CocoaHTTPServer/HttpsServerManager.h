//
//  HttpsServerManager.h
//  Lighting
//
//  Created by imvt on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
#import "UploadFileConnection.h"

#define KWebPath [[NSBundle mainBundle] pathForResource:@"Web" ofType:nil]

NS_ASSUME_NONNULL_BEGIN

@interface HttpsServerManager : NSObject

@property(nonatomic,strong)HTTPServer *localHttpServer;
@property(nonatomic,copy)NSString *port;

+ (instancetype)shareInstance;
- (void)configLocalHttpServer;

@end

NS_ASSUME_NONNULL_END
