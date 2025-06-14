#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface zxUpdateManager : NSObject

/// Initiates update check logic, including version comparison and display of update pill if needed.
+ (void)validityCheck;

/// Fetches latest App Store metadata for the given bundle ID and version.
+ (void)getAppInfoWithBundleId:(NSString *)bundleId
                currentVersion:(NSString *)cVersion;

/// Marks the current app as invalid (e.g. missing version info or not on App Store).
+ (void)markInvalidWithMsg:(NSString *)msg
                      text:(NSString *)text;

/// Shows a liquid pill overlay with update message and optional button action.
+ (void)notifyWithMsg:(NSString *)msg
           buttonText:(NSString *)bText
              handler:(nullable void (^)(UIAlertAction *action))handler;

@end

NS_ASSUME_NONNULL_END