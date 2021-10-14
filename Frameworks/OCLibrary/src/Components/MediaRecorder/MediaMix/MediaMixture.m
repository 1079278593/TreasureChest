//
//  MediaMixture.m
//  Poppy_Dev01
//
//  Created by jf on 2021/3/4.
//  Copyright © 2021 YLQTec. All rights reserved.
//

#import "MediaMixture.h"
#import <AVFoundation/AVFoundation.h>
#import "MediaConfig.h"

//degree
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MediaMixture ()

@end

@implementation MediaMixture

- (instancetype)init {
    if(self = [super init]){
        
    }
    return self;
}

#pragma mark - < public >
- (void)mediaRecordWithVideo:(MediaRecordModel *)video audio:(MediaRecordModel *)audio bgmMusic:(MediaRecordModel *)bgmMusic withCompletion:(MergeCompletion)completion {
   
    NSURL *videoURL = [NSURL fileURLWithPath:video.path];
    [self removeFileWithPath:[self outputPath]];
    NSString *outputPath = [self outputPath];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];// 输出路径：合并后的视频
    
    CMTime startTime = kCMTimeZero;// 开始时间
    AVMutableComposition *composition = [AVMutableComposition composition];// create composition
    
    //1.视频
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];// 获取视频资源
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoAsset.duration);// 要编辑的视频时间段
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;// video collect channel
    
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];// 合并‘轨道’用
    // add video collect channel data to a mutable channel
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];

    
    //2.音频。测试@[背景音，录音]
    NSArray *audios = @[audio,bgmMusic];//bgmMusic
    NSArray *parameters = [self audioMergeWithComposition:&composition audios:audios videoDuration:videoAsset.duration];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = parameters;
    
    
    //3. create output ,set quality
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeMPEG4;   // 输出类型
    assetExport.audioMix = audioMix;                // 音轨
    assetExport.outputURL = outputURL;              // 输出路径
    //这个视频如果旋转了，就不要加水印了。待解决。
//    assetExport.videoComposition = [self videoFix:videoAsset videoTrack:videoTrack degrees:90 isNeedWaterMark:NO];//加水印、旋转方向
    assetExport.shouldOptimizeForNetworkUse = YES;  // optimization
    // export
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        if (completion) {
            completion(outputPath);
        }
    }];
}

- (void)mediaOutputWithWaterMark:(MediaRecordModel *)video degrees:(CGFloat)degrees isNeedWaterMark:(BOOL)isNeedWaterMark  withCompletion:(MergeCompletion)completion {
    NSURL *videoURL = [NSURL fileURLWithPath:video.path];
    [self removeFileWithPath:[self outputPath]];
    NSString *outputPath = [self outputPath];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];// 输出路径：合并后的视频
    
    CMTime startTime = kCMTimeZero;// 开始时间
    AVMutableComposition *composition = [AVMutableComposition composition];// create composition
    
    //1.视频
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];// 获取视频资源
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoAsset.duration);// 要编辑的视频时间段
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;// video collect channel
    
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];// 合并‘轨道’用
    // add video collect channel data to a mutable channel
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];
    
    //2 获取视频的原有音轨
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //获取videoPath的音频插入轨道
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //3. create output ,set quality
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeMPEG4;   // 输出类型
//    assetExport.audioMix = [AVMutableAudioMix audioMix];                // 音轨
    assetExport.outputURL = outputURL;              // 输出路径
    assetExport.videoComposition = [self videoFix:videoAsset videoTrack:videoTrack degrees:degrees isNeedWaterMark:isNeedWaterMark];//加水印、旋转方向
    assetExport.shouldOptimizeForNetworkUse = YES;  // optimization
    // export
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        if (completion) {
            completion(outputPath);
        }
    }];
}

#pragma mark - < merge >
- (NSArray *)audioMergeWithComposition:(AVMutableComposition **)composition audios:(NSArray<MediaRecordModel *> *)audios videoDuration:(CMTime)duration {
    AVMutableComposition *_composition = *composition;
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i<audios.count; i++) {
        MediaRecordModel *audio = audios[i];
        NSString *path = audio.path;
        AudioType audioType = audio.audioType;
        if (path.length == 0) {
            continue;
        }
        AVMutableCompositionTrack *track = [_composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];//Can be default ,need try.
        [parameters addObject:inputParameters];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isExist = [fm fileExistsAtPath:path];
        NSURL *assetURL = [NSURL fileURLWithPath:path];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
//        Float64 videoTime = ceil(CMTimeGetSeconds(duration));//视频长度
        Float64 videoTime = CMTimeGetSeconds(duration);//视频长度
        Float64 audioTime = CMTimeGetSeconds(asset.duration);
        Float64 audioStartTime = 0.0f;
        
        if (audioType == AudioTypeBgm) {//背景音，先写死，后面要用滑块控制
            [inputParameters setVolume:audios[i].volume atTime:kCMTimeZero];
            Float64 cycleCounts = videoTime/audioTime;
            Float64 restTime = (cycleCounts - (int)cycleCounts)*audioTime;
            for (int i = 0; i<(int)cycleCounts; i++) {
                [track insertTimeRange:timeRange ofTrack:assetTrack atTime:CMTimeMake(audioTime*i*KTimeScale, KTimeScale) error:nil];
            }
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(restTime*KTimeScale, KTimeScale)) ofTrack:assetTrack atTime:CMTimeMake(audioTime*(int)cycleCounts*KTimeScale, KTimeScale) error:nil];
        }else if (audioType == AudioTypeRecord){//录音
            [inputParameters setVolume:audios[i].volume atTime:kCMTimeZero];
            CMTime startTime = CMTimeMake(audioStartTime*KTimeScale, KTimeScale);
            timeRange = CMTimeRangeMake(kCMTimeZero, duration);//录音用视频的长度
            NSError *error = nil;
            [track insertTimeRange:timeRange ofTrack:assetTrack atTime:startTime error:&error];
        }else {
            //先不处理
        }
    }    
    return parameters;
}

#pragma mark - < private >
- (NSString *)outputPath {
    NSString *docPath = NSTemporaryDirectory();
    NSString *outputPath = [docPath stringByAppendingPathComponent:@"mediaMerge.mp4"];
    return outputPath;
}

//因为要导出两次，这个作为中间的结果，待解决导出水印方向问题后处理.
- (NSString *)cachePath {
    NSString *docPath = NSTemporaryDirectory();
    NSString *outputPath = [docPath stringByAppendingPathComponent:@"mediaCacheMerge.mp4"];
    [self removeFileWithPath:outputPath];
    
    //将outputPath的文件移动到cachePath
    NSString *originPath = [self outputPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:originPath]) {
        [fm moveItemAtPath:[self outputPath] toPath:outputPath error:nil];
    }
    return outputPath;
}

- (void)removeFileWithPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        if (![fm removeItemAtPath:path error:nil]) {
            NSLog(@"remove old output file failed.");
        }
    }
}

- (AVMutableVideoComposition *)videoFix:(AVURLAsset *)videoAsset videoTrack:(AVAssetTrack *)videoTrack degrees:(CGFloat)degrees isNeedWaterMark:(BOOL)isNeedWaterMark {
    //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize naturalSize = videoAssetTrack.naturalSize;
    //防崩溃处理，这个width可能为空，按比例给他值
    if (naturalSize.width == 0) {
        CGFloat a = (1280.f / 720);
        naturalSize.width =  a * naturalSize.height;
    }
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    
    //AVMutableVideoComposition：管理所有视频轨道，水印添加就在这上面
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    videoComposition.frameDuration = CMTimeMake(1, 30);

    CGAffineTransform translate;
    //旋转。左上角
    if (degrees == 0) {
        videoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    }else if (degrees == 90) {
        // 顺时针旋转90°
        translate = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        translate = CGAffineTransformScale(translate, 1, -1);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        [videolayerInstruction setTransform:translate atTime:kCMTimeZero];
    } else if(degrees == 180){
        // 顺时针旋转180°
        //coding...
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        [videolayerInstruction setTransform:translate atTime:kCMTimeZero];
    } else if(degrees == 270){
        // 顺时针旋转270°
        //coding...
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        [videolayerInstruction setTransform:translate atTime:kCMTimeZero];
    }
    
    if (isNeedWaterMark) {//旋转后，如果加水印会导致之前的旋转也异常。所以，旋转的视频，不要加水印，先导出正常的后，在导出一遍。待解决这个问题。
        [self applyVideoEffectsToComposition:videoComposition size:naturalSize];
    }
    
    return videoComposition;
}

/** 
 设置水印及其对应视频的位置。如果AVMutableVideoCompositionLayerInstruction要旋转，下面的设置会影响前面的设置。
 
 @param composition 视频的结构
 @param size 视频的尺寸
 */
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
//    return;
    // 文字
//    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
//    //    [subtitle1Text setFont:@"Helvetica-Bold"];
//    [subtitle1Text setFontSize:36];
//    [subtitle1Text setFrame:CGRectMake(10, size.height-10-230, size.width, 100)];
//    [subtitle1Text setString:@"央视体育5 水印"];
//    //    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
//    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    //图片
    UIImage *image = [UIImage imageNamed:@"waterMark"];
    CALayer*picLayer = [CALayer layer];
    picLayer.contents = (id)image.CGImage; //本地图片
//    picLayer.contents = (id)self.videoWaterMarkImage.CGImage; //本地图片2
    //NSString *imageUrl = @"http://p1.img.cctvpic.com/photoAlbum/templet/special/PAGEQ1KSin2j2U5FERGWHp1h160415/ELMTnGlKHUJZi7lz19PEnqhM160415_1460715755.png";
    //picLayer.contents = (id)[self getImageFromURL:imageUrl].CGImage; //远程图片
    
    //设置位置（左下角坐标原点）
    CGFloat width = size.width/4.0;
    CGFloat height = width/(image.size.width/image.size.height);
    picLayer.frame = CGRectMake(size.width - width - 10, size.height-height-10, width, height);
//    picLayer.affineTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:picLayer];
//    [overlayLayer addSublayer:subtitle1Text];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CALayer *animationLayer = [CALayer layer];
    animationLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [animationLayer addSublayer:videoLayer];//先加videoLayer
    [animationLayer addSublayer:overlayLayer];//再加‘水印layer'
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:animationLayer];
    
}

@end
