//
//  HttpsServerManager.m
//  Lighting
//
//  Created by imvt on 2022/2/9.
//

#import "HttpsServerManager.h"
#import "NetworkTool.h"

@implementation HttpsServerManager

static HttpsServerManager *manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpsServerManager alloc]init];
        [manager copyWebToSandbox];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone {
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - < public >
- (void)startServer {
    [self configLocalHttpServer];
}

- (void)stopServer {
    [self.localHttpServer stop];
    _localHttpServer = nil;
}

- (NSString *)getServerUrl {
    return [NSString stringWithFormat:@"https://%@:%@",self.ip,self.port];
}

#pragma mark - < 搭建本地服务器 并且启动 >
- (void)configLocalHttpServer {
    _localHttpServer = [[HTTPServer alloc] init];
    [_localHttpServer setType:@"_http._tcp"];
//    [_localHttpServer setDomain:@"xxx.com"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = KWebRunPath;
    NSLog(@"搭建服务：[WebFilePath:]%@",path);
    
    
    if (![fileManager fileExistsAtPath:path]){
        NSLog(@"搭建服务： File path error!");
    }else{
        NSString *webLocalPath = path;
        [_localHttpServer setDocumentRoot:webLocalPath];//设置服务器的根目录
        [_localHttpServer setConnectionClass:[UploadFileConnection class]];
        NSLog(@"搭建服务：webLocalPath:%@",webLocalPath);
        [self startLocalServer];
    }
}

- (void)startLocalServer {
    NSError *error;
    if([_localHttpServer start:&error]){
        NSString *ip = [NetworkTool getIPAddress:YES];
        NSLog(@"开始服务：Started HTTP Server on port ---------%hu--------", [_localHttpServer listeningPort]);
        NSLog(@"开始服务：https://localhost:%hu ,手机用WKWeb打开",[_localHttpServer listeningPort]);
        NSLog(@"开始服务：https://%@:%hu  http还是https，如果输入不对无法访问",ip,[_localHttpServer listeningPort]);
        self.port = [NSString stringWithFormat:@"%d",[_localHttpServer listeningPort]];
    }
    else{
        NSLog(@"开始服务：Error starting HTTP Server: %@", error);
    }
}

- (void)copyWebToSandbox {
    NSString *webRunPath = KWebRunPath;
    NSString *webFilePath = KWebFilePath;
    [HttpsServerManager copyItemAtPath:webFilePath toPath:webRunPath overwrite:YES error:nil];
}

#pragma mark - 复制文件
/*参数1、被复制文件路径
 *参数2、要复制到的目标文件路径
 *参数3、当要复制到的文件路径文件存在，会复制失败，这里传入是否覆盖
 *参数4、错误信息
 */
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    //获得目标文件的上级目录
    NSString *toDirPath = [self directoryAtPath:toPath];
    if (![self isExistsAtPath:toDirPath]) {
        // 创建复制路径
        if (![self createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if (overwrite) {
        if ([self isExistsAtPath:toPath]) {
            [self removeItemAtPath:toPath error:error];
        }
    }
    // 复制文件，如果不覆盖且文件已存在则会复制失败
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}
 
#pragma mark - 判断文件(夹)是否存在
+ (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

/*创建文件
 *参数1：文件创建的路径
 *参数2：写入文件的内容
 *参数3：假如已经存在此文件是否覆盖
 *参数4：错误信息
 */
+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 如果文件夹路径不存在，那么先创建文件夹
    NSString *directoryPath = [self directoryAtPath:path];
    if (![self isExistsAtPath:directoryPath]) {
        // 创建文件夹
        if (![self createDirectoryAtPath:directoryPath error:error]) {
            return NO;
        }
    }
    // 如果文件存在，并不想覆盖，那么直接返回YES。
    if (!overwrite) {
        if ([self isExistsAtPath:path]) {
            return YES;
        }
    }
   /*创建文件
    *参数1：创建文件的路径
    *参数2：创建文件的内容（NSData类型）
    *参数3：文件相关属性
    */
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
 
    return isSuccess;
}

+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    /* createDirectoryAtPath:withIntermediateDirectories:attributes:error:
     * 参数1：创建的文件夹的路径
     * 参数2：是否创建媒介的布尔值，一般为YES
     * 参数3: 属性，没有就置为nil
     * 参数4: 错误信息
    */
    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    return isSuccess;
}

+ (NSString *)directoryAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

@end



