
//供参考，不使用

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, FsLayoutStatus){
    FsLayoutStatusNormal,
    FsLayoutStatusImageRight,
    FsLayoutStatusImageTop,
    FsLayoutStatusImageBottom,
};
@interface UIButton (FsLayout)
- (void)layoutWithStatus:(FsLayoutStatus)status andMargin:(CGFloat)margin;
@end
NS_ASSUME_NONNULL_END
