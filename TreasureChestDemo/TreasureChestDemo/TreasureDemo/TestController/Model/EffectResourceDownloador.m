//
//  EffectResourceDownloador.m
//  TreasureChest
//
//  Created by ming on 2021/3/29.
//  Copyright © 2021 xiao ming. All rights reserved.
//

#import "EffectResourceDownloador.h"
#import "FileManager.h"
#import "XMNetworking.h"

@implementation EffectResourceDownloador
/**
 //1.下载mask的tnn模型:tnnmodel和tnnproto，缩略图(),文件名用name
 
 //2.下载场景
 
 //3.下载lottie
 
 //4.
 */
- (void)startWithRequest {
    NSString *BaseURL_User = @"http://47.107.135.1:7005/api/v1/user";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    parameters[@"mobileModel"] = @"ios";
    parameters[@"appType"] = @1;    //应用类型[1：android，2：ios]
    
    NSString *url = [BaseURL_User stringByAppendingString:@"/ar/get"];
    [[XMNetworking sharedManager] GET:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        id response = responseObject[@"response"];
        EffectARealityModel *model = [EffectARealityModel mj_objectWithKeyValues:response];
        [self downloadWith:model];
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
    }];
}

- (void)downloadWith:(EffectARealityModel *)model {
    
    WS(weakSelf)
    //@"场景下载完成");
    NSArray *scenes = model.sceneList;
    for (EffectARScene *scene in scenes) {
        break;
        NSString *foldName = @"场景";
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",scene.name];
        NSString *picture = scene.picture;
        [[FileManager shareInstance] resourcePathWithType:FilePathTypeFaceBox foldName:foldName fileName:fileName url:picture complete:^(NSString * _Nonnull path) {

        }];
    }
    
    //lottie
    NSArray *lotties = model.decorateList;
    for (EffectARDecorate *lottie in lotties) {
        break;
        NSString *foldName = @"Lottie";
        NSString *fileName = [NSString stringWithFormat:@"%@.json",lottie.name];
        NSString *picture = lottie.url;
        [[FileManager shareInstance] resourcePathWithType:FilePathTypeFaceBox foldName:foldName fileName:fileName url:picture complete:^(NSString * _Nonnull path) {

        }];
    }
    
    //lut滤镜的图，普通滤镜不用
    NSArray *lutList = model.lutList;
    for (EffectARLut *lut in lutList) {
        break;
        NSString *foldName = @"Lut滤镜";
        NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg",lut.name,lut.type];
        NSString *picture = lut.picture;
        if (picture.length == 0) {
            continue;
        }
        [[FileManager shareInstance] resourcePathWithType:FilePathTypeFaceBox foldName:foldName fileName:fileName url:picture complete:^(NSString * _Nonnull path) {

        }];
    }
    
    //面具图+tnn模型相关，缩略图
    NSArray *maskList = model.maskList;
    for (EffectFaceMaskModel *mask in maskList) {
        break;
        NSString *foldName = mask.name;
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",foldName];
        NSString *picture = mask.picture;
        if (picture.length == 0) {
            continue;
        }
        [[FileManager shareInstance] resourcePathWithType:FilePathTypeFaceBox foldName:foldName fileName:fileName url:picture complete:^(NSString * _Nonnull path) {
            
        }];
        
        //轮廓分组
        NSString *path = [NSString stringWithFormat:@"%@/FaceBox/%@/轮廓分组.json",KDocument,foldName];
        [mask.outlineGroup writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        //纹理坐标
        path = [NSString stringWithFormat:@"%@/FaceBox/%@/纹理坐标.json",KDocument,foldName];
        [mask.textureCoordinate writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        //模型数据，只作用于漫画类型的面具。其它不管
        for (EffectARMaskModel *model in mask.modelDataList) {
            //tnnmodel
            NSString *foldName = mask.name;
            NSString *fileName = [NSString stringWithFormat:@"width_%d_level_%d.tnnmodel",model.modelWidth,model.level];
            NSString *picture = model.modelUrl;
            if (picture.length == 0) {
                continue;
            }
            [[FileManager shareInstance] resourcePathWithType:FilePathTypeFaceBox foldName:foldName fileName:fileName url:picture complete:^(NSString * _Nonnull path) {
            }];
            
            //tnnproto
            fileName = [NSString stringWithFormat:@"width_%d_level_%d.tnnproto",model.modelWidth,model.level];
            picture = model.protoUrl;
            if (picture.length == 0) {
                continue;
            }
            [[FileManager shareInstance] resourcePathWithType:FilePathTypeFaceBox foldName:foldName fileName:fileName url:picture complete:^(NSString * _Nonnull path) {
            }];
        }
    }
    
    //loading...阻塞
    
    //准备数据，下载：漫画模型、分割模型、lut、lottie
    //1.模型，只有漫画有，具体选哪个要根据：小窗、中窗、大窗
//    if (_maskModel.maskType == EffectMaskTypeCartoon) {
//        for (int i = 0; i<_maskModel.modelDataList.count; i++) {
//            EffectARMaskModel *cartoonModel = _maskModel.modelDataList[i];
//            NSString *modelFileName = [cartoonModel.modelUrl componentsSeparatedByString:@"/"].lastObject;
//            [[FileManager shareInstance] synResourcePathWithType:FilePathTypeFaceBox foldName:self.maskModel.name fileName:modelFileName url:cartoonModel.modelUrl complete:^(NSString * _Nonnull path) {
//            }];
//            
//            NSString *protoFileName = [cartoonModel.protoUrl componentsSeparatedByString:@"/"].lastObject;
//            [[FileManager shareInstance] synResourcePathWithType:FilePathTypeFaceBox foldName:self.maskModel.name fileName:protoFileName url:cartoonModel.protoUrl complete:^(NSString * _Nonnull path) {
//            }];
//        }
//    }
    
    //2. 分割模型，本地有一个，使用时需要根据手机配置来下载或者用本地。目前先用本地，不下载。待完成
        //待完成下载
    
    //3. lut
//    if (_filterModel.filterType == EffectsFilterTypeLut || _filterModel.filterType == EffectsFilterTypeLutGenerate) {
//        NSString *filterFileName = [_filterModel.picture componentsSeparatedByString:@"/"].lastObject;
//        [[FileManager shareInstance] synResourcePathWithType:FilePathTypeFaceBox foldName:_maskModel.name fileName:filterFileName url:_filterModel.picture complete:^(NSString * _Nonnull path) {
//        }];
//    }
    
    //4. lottie。
//    NSString *lottieFileName = [_decorateModel.url componentsSeparatedByString:@"/"].lastObject;
//    if (lottieFileName.length>0) {
//        [[FileManager shareInstance] synResourcePathWithType:FilePathTypeFaceBox foldName:KFaceBoxLottieFoldName fileName:lottieFileName url:_decorateModel.url complete:^(NSString * _Nonnull path) {
//            if (path.length > 0) {
//                [weakSelf.decorationStrata loadLottieWithPath:path url:weakSelf.decorateModel.url];
//            }
//        }];
//    }
}

@end
