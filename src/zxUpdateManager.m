##import "zxUpdateManager.h"
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
    NSString *regionCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] ?: @"US";

    NSString *reqURL = [NSString stringWithFormat:
        @"https://itunes.apple.com/lookup?bundleId=%@&country=%@",
        bundleId, regionCode];

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqURL]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self notifyWithMsg:[NSString stringWithFormat:@"Error checking for updates:\n%@", error.localizedDescription]
                     buttonText:@"Strange"
                        handler:nil];
            return;
        }

        NSError *jsonErr = nil;
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
        if (!resp || jsonErr) {
            os_log(OS_LOG_DEFAULT, "JSON parse failed: %@", jsonErr.localizedDescription);
            return;
        }

        if ([resp[@"resultCount"] isEqual:@0]) {
            [self markInvalidWithMsg:@"This app was not found on the App Store.\n\nP.S. Did you change the bundle ID?"
                                text:@"Okay"];
            return;
        }

NSDictionary *latest = resp[@"results"][0];
NSString *latestVersion = latest[@"version"];
NSString *releaseNotes = latest[@"releaseNotes"] ?: @"No notes provided.";
NSString *trackId = [latest[@"trackId"] stringValue];

if (releaseNotes.length > 300) {
    releaseNotes = [[releaseNotes substringToIndex:297] stringByAppendingString:@"..."];
}

NSDictionary *latestInfo = @{
    @"id": trackId,
    @"version": latestVersion,
    @"lastSeen": cVersion
};

os_log(OS_LOG_DEFAULT, "[zxUpdateManager] Latest info: %@", latestInfo);

if (![latestVersion isEqualToString:cVersion]) {
    [[NSUserDefaults standardUserDefaults] setObject:latestInfo forKey:@"zxAppInfo"];

    NSString *updMsg = [NSString stringWithFormat:
        @"An update is available!\n\nv%@ → v%@\n\n📝 %@",
        cVersion, latestVersion, releaseNotes];

    NSString *storeLink = [NSString stringWithFormat:@"https://apps.apple.com/app/id%@", trackId];

    [self notifyWithMsg:updMsg
             buttonText:@"Let me see!"
                handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:storeLink]
                                           options:@{}
                                 completionHandler:nil];
    }];
}

+ (void)markInvalidWithMsg:(NSString *)msg text:(NSString *)text {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zxAvoidUpdates"];
    [self showLiquidPillWithText:msg buttonText:text tapHandler:nil];
}

+ (void)notifyWithMsg:(NSString *)msg buttonText:(NSString *)bText handler:(void (^)(UIAlertAction *action))handler {
    os_log(OS_LOG_DEFAULT, "[zxUpdateManager] Displaying pill overlay: %@", msg);
    [self showLiquidPillWithText:msg buttonText:bText tapHandler:handler];
}

+ (void)showLiquidPillWithText:(NSString *)message buttonText:(NSString *)buttonText tapHandler:(void (^)(UIAlertAction *action))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        if (!window) return;

        CGFloat pillWidth = window.bounds.size.width - 40;
        UIView *pillView = [[UIView alloc] initWithFrame:CGRectMake(20, window.bounds.size.height - 120, pillWidth, 80)];
        pillView.layer.cornerRadius = 20;
        pillView.layer.masksToBounds = YES;
        pillView.alpha = 0;

        UIBlurEffectStyle style = UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ?
            UIBlurEffectStyleSystemThickDark : UIBlurEffectStyleSystemMaterialLight;
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        blurView.frame = pillView.bounds;
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [pillView addSubview:blurView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(pillView.bounds, 20, 10)];
        NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
        NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
        NSString *region = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

        NSString *timestamp = [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]];
NSString *statusLine = [message containsString:@"update"] ? @"⬆️ Update available" : @"✅ Up to date";

label.text = [NSString stringWithFormat:
    @"📦 %@\n🌏 %@ | v%@\n🕒 %@\n%@\n\n%@", 
    bundleId, region, version, timestamp, statusLine, message];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.labelColor;
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [pillView addSubview:label];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePillTap:)];
        [pillView addGestureRecognizer:tap];
        pillView.userInteractionEnabled = YES;
        pillView.tag = 9911;

        [window addSubview:pillView];

        [UIView animateWithDuration:0.3 animations:^{
            pillView.alpha = 1.0;
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIView *existing = [window viewWithTag:9911];
            if (existing) {
                [UIView animateWithDuration:0.3 animations:^{
                    existing.alpha = 0;
                } completion:^(BOOL finished) {
                    [existing removeFromSuperview];
                }];
            }
        });
    });
}

+ (void)handlePillTap:(UITapGestureRecognizer *)gesture {
    UIView *pill = gesture.view;
    if (pill) {
        [UIView animateWithDuration:0.3 animations:^{
            pill.alpha = 0;
        } completion:^(BOOL finished) {
            [pill removeFromSuperview];
    }];
}
@end