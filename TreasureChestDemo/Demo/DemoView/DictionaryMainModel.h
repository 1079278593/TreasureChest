//
//  DictionaryMainModel.h
//  TreasureChest
//
//  Created by xiao ming on 2020/1/17.
//  Copyright © 2020 xiao ming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DictionaryMainModel : NSObject
@property(strong, nonatomic)NSString *word;
@property(strong, nonatomic)NSString *sw;
@property(strong, nonatomic)NSString *phonetic;
@property(strong, nonatomic)NSString *definition;
@property(strong, nonatomic)NSString *translation;
@property(strong, nonatomic)NSString *pos;
@property(strong, nonatomic)NSString *collins;
@property(strong, nonatomic)NSString *oxford;
@property(strong, nonatomic)NSString *tag;
@property(strong, nonatomic)NSString *bnc;
@property(strong, nonatomic)NSString *frq;
@property(strong, nonatomic)NSString *exchange;
@property(strong, nonatomic)NSString *detail;
@property(strong, nonatomic)NSString *audio;
@end

NS_ASSUME_NONNULL_END

/**
 word    单词名称
 phonetic    音标，以英语英标为主
 definition    单词释义（英文），每行一个释义
 translation    单词释义（中文），每行一个释义
 pos    词语位置，用 "/" 分割不同位置
 collins    柯林斯星级
 oxford    是否是牛津三千核心词汇
 tag    字符串标签：zk/中考，gk/高考，cet4/四级 等等标签，空格分割
 bnc    英国国家语料库词频顺序
 frq    当代语料库词频顺序
 exchange    时态复数等变换，使用 "/" 分割不同项目，见后面表格
 detail    json 扩展信息，字典形式保存例句（待添加）
 audio    读音音频 url （待添加）
 
 */
