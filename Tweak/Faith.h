//
//  Faith.h
//  Faith
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>

@class FaithViewController;

NSDictionary* nowPlayingInfo;

NSUserDefaults* preferences;
BOOL pfEnabled;

@interface CSCoverSheetView : UIView
@property(nonatomic)FaithViewController* faithViewController;
- (void)presentFaith;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (void)setNowPlayingInfo:(NSDictionary *)nowPlayingInfo;
@end

@interface UISystemShellApplication : UIApplication
@end

@interface SpringBoard : UISystemShellApplication
@end
