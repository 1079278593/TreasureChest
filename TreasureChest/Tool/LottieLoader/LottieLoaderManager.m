//
//  LottieLoaderManager.m
//  TreasureChest
//
//  Created by ming on 2021/2/28.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "LottieLoaderManager.h"
#import "LottieLoader.h"

static LottieLoaderManager *manager = nil;

@interface LottieLoaderManager ()

@property(nonatomic, strong)NSMutableArray <LottieLoader *> *loaders;
@property(nonatomic, strong)LottieLoader *currentLoader;

@end

@implementation LottieLoaderManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LottieLoaderManager alloc]init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return manager;
}

- (instancetype)init {
    if(self == [super init]){
    }
    return self;
}

#pragma mark - < public >
- (void)loadWithPath:(NSString *)path url:(NSString *)url {
    if (path.length == 0 && url.length == 0) {
        return;
    }
    for (LottieLoader *loader in self.loaders) {
        BOOL isContainPath = [loader.path isEqualToString:path] && path.length > 0;
        BOOL isContainUrl = [loader.url isEqualToString:url] && url.length > 0;
        if (isContainPath || isContainUrl) {
            loader.path = path;
            loader.url = url;
            self.currentLoader = loader;
            return;
        }
    }
    //清理
    [self deleteOutLoader];
    
    LottieLoader *loader;
    if (path.length >= 0) { //优先用本地的资源加载
        loader = [[LottieLoader alloc]initWithPath:path];
        loader.url = url;
    }else {
        loader = [[LottieLoader alloc]initWithUrl:url];
        loader.path = path;
    }
    NSLog(@"切换 ");
    [self.loaders addObject:loader];
    self.currentLoader = loader;
}

- (CVPixelBufferRef)pixelBufferWithProgress:(CGFloat)progress {
    return [self.currentLoader pixelBufferWithProgress:progress];
}

- (void)clean {
    for (LottieLoader *loader in self.loaders) {
        [loader clean];
    }
    [self.loaders removeAllObjects];
}

#pragma mark - < private >
- (void)deleteOutLoader {
    if (self.loaders.count >= KLottieLoaderCacheCount) {
        LottieLoader *loader;
        if ([self.loaders.firstObject isEqual:self.currentLoader]) {
            loader = self.loaders[1];
        }else {
            loader = self.loaders[0];
        }
        [loader clean];
        [self.loaders removeObject:loader];
    }
}

#pragma mark - < getter >
- (NSMutableArray<LottieLoader *> *)loaders {
    if (_loaders == nil) {
        _loaders = [NSMutableArray arrayWithCapacity:0];
    }
    return _loaders;
}

@end
