//
//  EasySocketModel.h
//  Lighting
//
//  Created by imvt on 2022/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EasySocketModel : NSObject

///完整的数据
@property(nonatomic, strong, readonly)NSString *response;

///按行分割后的内容
@property(nonatomic, strong, readonly)NSMutableArray *contents;

///返回的内容中是否包含请求状态：OK
@property(nonatomic, assign, readonly)BOOL isResponeseOk;

///获取head之外的内容，可能为nil
@property(nonatomic, strong, readonly)NSString *responseContent;

- (void)decodeWithResponseData:(NSData *)responseData;

- (BOOL)isValidResponse:(NSString *)response;

@end

NS_ASSUME_NONNULL_END
