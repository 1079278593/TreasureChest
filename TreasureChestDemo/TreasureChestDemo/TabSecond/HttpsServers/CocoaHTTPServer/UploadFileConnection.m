//
//  UploadFileConnection.m
//  Lighting
//
//  Created by imvt on 2021/12/10.
//

#import "UploadFileConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

@interface UploadFileConnection () {
    MultipartFormDataParser *parser;
    NSFileHandle *storeFile;
    NSMutableArray *uploadedFiles;
}

@end

@implementation UploadFileConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    // Add support for POST
    if ([method isEqualToString:@"POST"]) {
        if ([path isEqualToString:KUploadFilePath]) {
            return YES;
        }
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    // Inform HTTP server that we expect a body to accompany a POST request
    if([method isEqualToString:@"POST"] && [path isEqualToString:KUploadFilePath]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    if ([method isEqualToString:@"POST"] && [path isEqualToString:KUploadFilePath]) {
        // this method will generate response with links to uploaded file
        NSMutableString* filesStr = [[NSMutableString alloc] init];
        
        for( NSString* filePath in uploadedFiles ) {
            //generate links
            [filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
        }
        NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:KUploadFileName];
        NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];//定位upload.html的MyFiles，将被filesStr替换
        // use dynamic file response to apply our links to response template
        return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
    }
    if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
        // let download the uploaded files
        NSString *saveReceivedFilePath = [self firmwarePath];
        return [[HTTPFileResponse alloc] initWithFilePath: [saveReceivedFilePath stringByAppendingString:path] forConnection:self];
//        return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
    }
    if( [method isEqualToString:@"GET"] && ([path hasPrefix:@"/upgrade/"] || [path hasPrefix:@"/upgrade"]) ) {
        // let download the uploaded files
//        return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
        
        //将文件返回
//        NSString *filPth = [@"/Users/imvt/Desktop" stringByAppendingString:@"/apps.pem"];
        NSString *filPth = [NSString stringWithFormat:@"%@/lighting.bin",[config documentRoot]];
        return [[HTTPFileResponse alloc] initWithFilePath: filPth forConnection:self];
    }
    
    return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk {
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate
- (void)processStartOfPartWithHeader:(MultipartMessageHeader*)header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    //    NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    uploadDirPath = [NSString stringWithFormat:@"%@/%@",uploadDirPath,@"lighting/upload"];
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //收到文件保存的位置
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        storeFile = nil;
    }
    else {
        if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
        }
        if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
        }
        storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
    }
}

- (void)processContent:(NSData*)data WithHeader:(MultipartMessageHeader*)header {
    // here we just write the output from parser to the file.
    if( storeFile ) {
        [storeFile writeData:data];
    }
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*)header {
    // as the file part is over, we close the file.
    [storeFile closeFile];
    storeFile = nil;
    NSLog(@"----1-----upload EndOfPartWithHeader");//这里可以作为结束的标志时间点
}

- (void) processPreambleData:(NSData*)data {
    // if we are interested in preamble data, we could process it here.
    NSLog(@"----2-----upload EprocessPreambleData");
}

- (void) processEpilogueData:(NSData*)data {
    // if we are interested in epilogue data, we could process it here.
    NSLog(@"----3-----upload EprocessEpilogueData");
}

///保存传入手机的文件，到
- (NSString *)firmwarePath {
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    uploadDirPath = [NSString stringWithFormat:@"%@/",uploadDirPath]
    
    return uploadDirPath;
}

@end
