//
//  CameraMediaItem.m
//  TreasureChest
//
//  Created by imvt on 2023/10/7.
//  Copyright © 2023 xiao ming. All rights reserved.
//

#import "CameraMediaItem.h"

@implementation CameraMediaInfo

- (NSString*)resolutionText
{
    if (self.h == 1080) {
        return @"1080P";
    } else if (self.h == 720) {
        return @"720P";
    } else if (self.h == 960) {
        return @"960P";
    } else if (self.w == 3840) {
        return @"4K";
    } else if (self.w == 4096) {
        return @"4096P";
    } else if (self.w == 848 || self.w == 840) {
        return @"WVGA";
    } else if (self.h == 2160){
        return @"2160P";
    } else if (self.h == 1920){
        return @"1920P";
    } else if (self.h == 1440){
        return @"1440P";
    } else if (self.h == 2432){
        return @"2432P";
    } else if (self.h == 600){
        return @"SVGAP";
    } else if (self.h == 384){
        return @"384P";
    } else if (self.h == 1728){
        return @"1728P";
    } else {
        return [NSString stringWithFormat:@"%dP", self.h];
    }
}

@end

@implementation CameraMediaItem

- (id)initWithFolderName:(NSString *)folderName fileName:(NSString *)fileName
{
    self = [super init];
    if (self) {
        _fileName = fileName;
        _folderName = folderName;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CameraMediaItem class]]) {
        CameraMediaItem *item = (CameraMediaItem*)object;
        if ([item.folderName isEqualToString:self.folderName]
            && [item.fileName isEqualToString:self.fileName]) {
            return YES;
        }
    }
    return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@/%@", self.folderName, self.fileName];
}

- (BOOL)isVideo
{
    NSString *fileType = [self.fileName pathExtension];
    if ([fileType caseInsensitiveCompare:@"JPG"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"JPEG"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"PNG"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"RAW"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"BMP"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"DNG"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"HEIC"] == NSOrderedSame ||
        [fileType caseInsensitiveCompare:@"HEIF"] == NSOrderedSame) {
        return NO;
    } else {
        return YES;
    }
}

@end
