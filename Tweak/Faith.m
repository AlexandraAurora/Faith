//
//  Faith.m
//  Faith
//
//  Created by Alexandra Aurora Göttlicher
//

#import "Faith.h"
#import <substrate.h>
#import <MediaRemote/MediaRemote.h>
#import "Controllers/FaithViewController.h"
#import "../Preferences/PreferenceKeys.h"
#import "../Preferences/NotificationKeys.h"

CSCoverSheetView* coverSheetView;


@interface SBVolumeControl : NSObject
@end
static void (* orig_SBVolumeControl_increaseVolume)(SBVolumeControl* self, SEL _cmd);
static void override_SBVolumeControl_increaseVolume(SBVolumeControl* self, SEL _cmd) {
    orig_SBVolumeControl_increaseVolume(self, _cmd);

    [coverSheetView presentFaith];
}


#pragma mark - CSCoverSheetView class properties

static FaithViewController* faithViewController(CSCoverSheetView* self, SEL _cmd) {
    return (FaithViewController *)objc_getAssociatedObject(self, (void *)faithViewController);
};
static void setFaithViewController(CSCoverSheetView* self, SEL _cmd, FaithViewController* rawValue) {
    objc_setAssociatedObject(self, (void *)faithViewController, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - CSCoverSheetView class hooks

/**
 * Example hook.
 */
static void (* orig_CSCoverSheetView_didMoveToWindow)(CSCoverSheetView* self, SEL _cmd);
static void override_CSCoverSheetView_didMoveToWindow(CSCoverSheetView* self, SEL _cmd) {
	orig_CSCoverSheetView_didMoveToWindow(self, _cmd);

    if (coverSheetView) {
        return;
    }
    coverSheetView = self;

    [self setFaithViewController:[[FaithViewController alloc] init]];
}

static void CSCoverSheetView_presentFaith(CSCoverSheetView* self, SEL _cmd) {
    [[coverSheetView faithViewController] updateWithNowPlayingInfo:nowPlayingInfo];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:[coverSheetView faithViewController] animated:YES completion:nil];
}

#pragma mark - SBMediaController class hooks

/**
 * Example hook.
 */
static void (* orig_SBMediaController_setNowPlayingInfo)(SBMediaController* self, SEL _cmd, NSDictionary* info);
static void override_SBMediaController_setNowPlayingInfo(SBMediaController* self, SEL _cmd, NSDictionary* info) {
	orig_SBMediaController_setNowPlayingInfo(self, _cmd, info);

    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        if (information) {
            nowPlayingInfo = (__bridge NSDictionary *)information;

            // if ([[coverSheetView faithViewController] isBeingPresented]) {
                [[coverSheetView faithViewController] updateWithNowPlayingInfo:nowPlayingInfo];
            // }
        }
  	});
}

#pragma mark - SpringBoard class hooks

/**
 * Example hook.
 */
static void (* orig_SpringBoard_applicationDidFinishLaunching)(SpringBoard* self, SEL _cmd, id arg1);
static void override_SpringBoard_applicationDidFinishLaunching(SpringBoard* self, SEL _cmd, id arg1) {
	orig_SpringBoard_applicationDidFinishLaunching(self, _cmd, arg1);
    [[objc_getClass("SBMediaController") sharedInstance] setNowPlayingInfo:0];
}

#pragma mark - Preferences

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue)
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
}

#pragma mark - Constructor

/**
 * Initializes Faith.
 *
 * First it loads the preferences and continues if Faith is enabled.
 * Secondly it sets up the hooks.
 * Finally it registers the notification callbacks.
 */
__attribute((constructor)) static void initialize() {
	load_preferences();

    if (!pfEnabled) {
        return;
    }

    class_addMethod(objc_getClass("CSCoverSheetView"), @selector(presentFaith), (IMP)&CSCoverSheetView_presentFaith, "v@:");

    class_addProperty(NSClassFromString(@"CSCoverSheetView"), "faithViewController", (objc_property_attribute_t[]){{"T", "@\"FaithViewController\""}, {"N", ""}, {"V", "_faithViewController"}}, 3);
    class_addMethod(NSClassFromString(@"CSCoverSheetView"), @selector(faithViewController), (IMP)&faithViewController, "@@:");
    class_addMethod(NSClassFromString(@"CSCoverSheetView"), @selector(setFaithViewController:), (IMP)&setFaithViewController, "v@:@");

    MSHookMessageEx(objc_getClass("SBVolumeControl"), @selector(increaseVolume), (IMP)&override_SBVolumeControl_increaseVolume, (IMP *)&orig_SBVolumeControl_increaseVolume);
    MSHookMessageEx(objc_getClass("CSCoverSheetView"), @selector(didMoveToWindow), (IMP)&override_CSCoverSheetView_didMoveToWindow, (IMP *)&orig_CSCoverSheetView_didMoveToWindow);
	MSHookMessageEx(objc_getClass("SBMediaController"), @selector(setNowPlayingInfo:), (IMP)&override_SBMediaController_setNowPlayingInfo, (IMP *)&orig_SBMediaController_setNowPlayingInfo);
    MSHookMessageEx(objc_getClass("SpringBoard"), @selector(applicationDidFinishLaunching:), (IMP)&override_SpringBoard_applicationDidFinishLaunching, (IMP *)&orig_SpringBoard_applicationDidFinishLaunching);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
