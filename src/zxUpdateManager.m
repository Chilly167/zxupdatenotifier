#import "zxUpdateManager.h"
#import <os/log.h>
#import <UIKit/UIKit.h>

@implementation zxUpdateManager

+ (void)validityCheck {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"zxAvoidUpdates"]) return;

    NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    if (!version) {
        [self markInvalidWithMsg:@"This app does not contain CFBundleShortVersionString and is incompatible with zxUpdateManager."
                            text:@"Okay"];
        return;
    }

    NSDictionary *latestInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"zxAppInfo"];
    if (!latestInfo || ![latestInfo[@"lastSeen"] isEqualToString:version]) {
        os_log(OS_LOG_DEFAULT, "[zxUpdateManager] Checking for updates with version: %@", version);
        [self getAppInfoWithBundleId:NSBundle.mainBundle.bundleIdentifier currentVersion:version];
    }
}

+ (void)getAppInfoWithBundleId:(NSString *)bundleId currentVersion:(NSString *)cVersion {
    // Auto-detect region
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (!regionCode) regionCode = @"US"; // Fallback

    NSString *reqURL = [NSString stringWithFormat:
        @"https://itunes.apple.com/lookup?limit=1&hi=%@&bundleId=%@&country=%@",
        NSUUID.UUID.UUIDString, bundleId, regionCode];

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqURL]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self notifyWithMsg:[NSString stringWithFormat:@"Error checking for updates:\n%@", error.localizedDescription]
                     buttonText:@"Strange"
                        handler:nil];
            return;
        }

        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        if ([resp[@"resultCount"] isEqual:@0]) {
            [self markInvalidWithMsg:@"This app was not found on the App Store.\n\nP.S. Did you change the bundle ID?"
                                text:@"Okay"];
            return;
        }

        NSDictionary *latest = resp[@"results"][0];
        NSString *latestVersion = latest[@"version"];
        NSString *trackId = [latest[@"trackId"] stringValue];

        NSDictionary *latestInfo = @{
            @"id": trackId,
            @"version": latestVersion,
            @"lastSeen": cVersion
        };

        os_log(OS_LOG_DEFAULT, "[zxUpdateManager] Latest info: %@", latestInfo);

        if (![latestVersion isEqualToString:cVersion]) {
            [[NSUserDefaults standardUserDefaults] setObject:latestInfo forKey:@"zxAppInfo"];

            NSString *updMsg = [NSString stringWithFormat:@"An update is available!\n\nv%@ → v%@", cVersion, latestVersion];
            NSString *storeLink = [NSString stringWithFormat:@"https://apps.apple.com/app/id%@", trackId];

            [self notifyWithMsg:updMsg
                     buttonText:@"Let me see!"
                        handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeLink]
                                                   options:@{}
                                         completionHandler:nil];
            }];
        }
    }] resume];
}

+ (void)markInvalidWithMsg:(NSString *)msg text:(NSString *)text {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zxAvoidUpdates"];
    [self notifyWithMsg:msg buttonText:text handler:nil];
}

+ (void)notifyWithMsg:(NSString *)msg buttonText:(NSString *)bText handler:(void (^)(UIAlertAction *action))handler {
    os_log(OS_LOG_DEFAULT, "[zxUpdateManager] Displaying popup: %@", msg);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"zxUpdateNotifier"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *act = [UIAlertAction actionWithTitle:bText
                                                      style:UIAlertActionStyleDefault
                                                    handler:handler];

        [alert addAction:act];

        UIWindow *keyWindow = UIApplication.sharedApplication.windows.firstObject;
        UIViewController *rvc = keyWindow.rootViewController;
        while (rvc.presentedViewController) {
            rvc = rvc.presentedViewController;
        }
        [rvc presentViewController:alert animated:YES completion:nil];
    });
}

@end