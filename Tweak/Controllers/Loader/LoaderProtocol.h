//
//  LoaderProtocol.h
//  Faith
//
//  Created by Alexandra Aurora Göttlicher
//

#import <Foundation/Foundation.h>

@protocol LoaderProtocol <NSObject>
@required
- (void)fetchLyricsForTerm:(NSString *)term completion:(void (^)(NSString *))completion;
@end
