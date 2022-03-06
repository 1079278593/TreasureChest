//
//  HttpsServerManager.h
//  Lighting
//
//  Created by imvt on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
#import "UploadFileConnection.h"

///web在项目中的位置
#define KWebFilePath [[NSBundle mainBundle] pathForResource:@"Web" ofType:nil]
///Web要拷贝到的目标位置（主要是沙盒里可以控制下载和上传的内容，因为Web是作为https服务的根目录）
#define KWebRunPath [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"Web/"]

NS_ASSUME_NONNULL_BEGIN

@interface HttpsServerManager : NSObject

@property(nonatomic,strong)HTTPServer *localHttpServer;
@property(nonatomic,copy)NSString *port;

+ (instancetype)shareInstance;
- (void)configLocalHttpServer;

@end

NS_ASSUME_NONNULL_END
