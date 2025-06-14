#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface zxUpdateManager : NSObject

+ (void)validityCheck;

+ (void)getAppInfoWithBundleId:(NSString *)bundleId
               currentVersion:(NSString *)cVersion;

+ (void)markInvalidWithMsg:(NSString *)msg
                      text:(NSString *)text;

+ (void)notifyWithMsg:(NSString *)msg
           buttonText:(NSString *)bText
              handler:(nullable void (^)(UIAlertAction *action))handler;

@end

NS_ASSUME_NONNULL_END