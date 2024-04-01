//
//  FaithViewController.m
//  Faith
//
//  Created by Alexandra Aurora Göttlicher
//

#import "FaithViewController.h"
#import <MediaRemote/MediaRemote.h>
#import "Loader/GeniusLoader.h"

@implementation FaithViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [[self view] setBackgroundColor:[UIColor systemBackgroundColor]];

    [self setArtworkImageView:[[UIImageView alloc] init]];
    [[self artworkImageView] setContentMode:UIViewContentModeScaleAspectFill];
    [[self view] addSubview:[self artworkImageView]];

    [[self artworkImageView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self artworkImageView] topAnchor] constraintEqualToAnchor:[[self view] topAnchor]],
        [[[self artworkImageView] leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor]],
        [[[self artworkImageView] trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor]],
        [[[self artworkImageView] bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor]]
    ]];

    [self setBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    [self setBlurEffectView:[[UIVisualEffectView alloc] initWithEffect:[self blurEffect]]];
    [[self view] addSubview:[self blurEffectView]];

    [[self blurEffectView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self blurEffectView] topAnchor] constraintEqualToAnchor:[[self view] topAnchor]],
        [[[self blurEffectView] leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor]],
        [[[self blurEffectView] trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor]],
        [[[self blurEffectView] bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor]]
    ]];

    [self setGrabber:[[_UIGrabber alloc] init]];
    [[self view] addSubview:[self grabber]];

    [[self grabber] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self grabber] topAnchor] constraintEqualToAnchor:[[self view] topAnchor] constant:12],
        [[[self grabber] centerXAnchor] constraintEqualToAnchor:[[self view] centerXAnchor]]
    ]];

    [self setTitleLabel:[[UILabel alloc] init]];
    [[self titleLabel] setFont:[UIFont systemFontOfSize:26 weight:UIFontWeightSemibold]];
    [[self titleLabel] setTextColor:[UIColor labelColor]];
    [[self titleLabel] setMarqueeEnabled:YES];
    [[self titleLabel] setMarqueeRunning:YES];
    [[self view] addSubview:[self titleLabel]];

    [[self titleLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self titleLabel] topAnchor] constraintEqualToAnchor:[[self grabber] topAnchor] constant:16],
        [[[self titleLabel] leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor] constant:16],
        [[[self titleLabel] trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor] constant:-16]
    ]];

    [self setArtistLabel:[[UILabel alloc] init]];
    [[self artistLabel] setFont:[UIFont systemFontOfSize:19 weight:UIFontWeightRegular]];
    [[self artistLabel] setTextColor:[UIColor secondaryLabelColor]];
    [[self artistLabel] setMarqueeEnabled:YES];
    [[self artistLabel] setMarqueeRunning:YES];
    [[self view] addSubview:[self artistLabel]];

    [[self artistLabel] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self artistLabel] topAnchor] constraintEqualToAnchor:[[self titleLabel] bottomAnchor] constant:2],
        [[[self artistLabel] leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor] constant:16],
        [[[self artistLabel] trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor] constant:-16]
    ]];

    [self setLyricsTextView:[[UITextView alloc] init]];
    [[self lyricsTextView] setBackgroundColor:[UIColor clearColor]];
    [[self lyricsTextView] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
    [[self lyricsTextView] setTextColor:[UIColor labelColor]];
    [[self lyricsTextView] setEditable:NO];
    [[self lyricsTextView] setScrollEnabled:YES];
    [[self view] addSubview:[self lyricsTextView]];

    [[self lyricsTextView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [[[self lyricsTextView] topAnchor] constraintEqualToAnchor:[[self artistLabel] bottomAnchor] constant:16],
        [[[self lyricsTextView] leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor] constant:16],
        [[[self lyricsTextView] trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor] constant:-16],
        [[[self lyricsTextView] bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor] constant:-16]
    ]];
}

- (void)updateWithNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    NSLog(@"[FAITH] updating lyrics");

    if (nowPlayingInfo) {
        UIImage* songArtwork = [self getArtworkFromNowPlayingInfo:nowPlayingInfo];
        NSString* songTitle = [self getTitleFromNowPlayingInfo:nowPlayingInfo];
        NSString* songArtist = [self getArtistFromNowPlayingInfo:nowPlayingInfo];

        [[self artworkImageView] setImage:songArtwork];
        [[self titleLabel] setText:songTitle];
        [[self artistLabel] setText:songArtist];
        [[self lyricsTextView] setText:@"Fetching lyrics..."];

        NSString* term = [NSString stringWithFormat:@"%@ %@", songTitle, songArtist];
        NSLog(@"[FAITH] new term: %@", term);
        NSLog(@"[FAITH] last term: %@", term);
        if ([_lastLyricsTerm isEqualToString:term]) {
            return;
        }
        _lastLyricsTerm = term;

        // Fetch and set the lyrics.
        id loader = [[GeniusLoader alloc] init];

        [loader fetchLyricsForTerm:term completion:^(NSString* lyrics) {
            [self setLyrics:lyrics];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[self lyricsTextView] setText:lyrics];

                // Scroll to the top.
                [[self lyricsTextView] setContentOffset:CGPointMake(0, -[self lyricsTextView].contentInset.top) animated:YES];
            });
        }];
    }
}

- (UIImage *)getArtworkFromNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    NSData* artworkData = nowPlayingInfo[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
    return [UIImage imageWithData:artworkData];
}

- (NSString *)getTitleFromNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    return nowPlayingInfo[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
}

- (NSString *)getArtistFromNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    return nowPlayingInfo[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
}
@end
