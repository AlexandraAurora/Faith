//
//  FaithViewController.h
//  Faith
//
//  Created by Alexandra Aurora Göttlicher
//

#import <UIKit/UIKit.h>

@interface _UIGrabber : UIControl
@end

@interface FaithViewController : UIViewController {
    NSString* _lastLyricsTerm;
}
@property(nonatomic)UIImageView* artworkImageView;
@property(nonatomic)UIBlurEffect* blurEffect;
@property(nonatomic)UIVisualEffectView* blurEffectView;
@property(nonatomic)_UIGrabber* grabber;
@property(nonatomic)UILabel* titleLabel;
@property(nonatomic)UILabel* artistLabel;
@property(nonatomic)UITextView* lyricsTextView;
@property(nonatomic)NSString* lyrics;
- (void)updateWithNowPlayingInfo:(NSDictionary *)nowPlayingInfo;
@end

@interface UILabel (Private)
- (void)setMarqueeEnabled:(BOOL)enabled;
- (void)setMarqueeRunning:(BOOL)enabled;
@end
