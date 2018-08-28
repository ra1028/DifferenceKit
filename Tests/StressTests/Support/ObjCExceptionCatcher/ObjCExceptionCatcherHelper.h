#import <Foundation/Foundation.h>

@interface ObjCExceptionCatcherHelper: NSObject

+ (void)try:(nonnull NS_NOESCAPE void(^)(void))tryBlock
      catch:(nonnull void(^)(NSException * _Nonnull))catchBlock
    finally:(nonnull void(^)(void))finallyBlock;

@end
