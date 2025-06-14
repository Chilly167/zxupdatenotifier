#import "zxUpdateManager.h"

__attribute__((constructor)) static void zxUpdateNotifierInit() {
    @autoreleasepool {
        NSLog(@"[zxUpdateNotifier] Scheduling validityCheck...");

        // Slight delay to ensure UIApplication is ready
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [zxUpdateManager validityCheck];
        });
    }