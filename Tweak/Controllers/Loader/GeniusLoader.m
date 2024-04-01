//
//  GeniusLoader.m
//  Faith
//
//  Created by Alexandra Aurora Göttlicher
//

#import "GeniusLoader.h"

@implementation GeniusLoader
- (void)fetchLyricsForTerm:(NSString *)term completion:(void (^)(NSString *))completion {
    term = [term stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self fetchGeniusSongUrlForTerm:term completion:^(NSURL* geniusSongUrl) {
        if (geniusSongUrl) {
            NSData* songPageData = [NSData dataWithContentsOfURL:geniusSongUrl];
            if (!songPageData) {
                completion(@"Failed to fetch lyrics.");
            }

            NSString* html = [[NSString alloc] initWithData:songPageData encoding:NSUTF8StringEncoding];

            // Get the content of all lyrics containers.
            NSString* pattern = @"class=\"Lyrics__Container-[^\"]*\">(.*?)<\\/div>";
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
            NSArray* matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];

            // Loop through all matches and concatenate the content.
            // This is necessary, because the lyrics are split into multiple divs/containers (at least on the mobile layout).
            NSMutableString* lyricsHtml = [NSMutableString string];
            for (NSTextCheckingResult* match in matches) {
                NSRange matchRange = [match rangeAtIndex:1];
                NSString* matchString = [html substringWithRange:matchRange];
                [lyricsHtml appendString:matchString];
            }

            NSString* lyrics = [lyricsHtml copy];

            // Decode the HTML entities to get rid of &quot; etc.
            NSAttributedString* attributedString = [[NSAttributedString alloc] initWithData:[lyrics dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
            lyrics = [attributedString string];

            // Replace <br/> with newlines.
            lyrics = [lyrics stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];

            completion(lyrics);
        } else {
            completion(@"No lyrics found.");
        }
    }];
}

- (void)fetchGeniusSongUrlForTerm:(NSString *)term completion:(void (^)(NSURL* geniusSongUrl))completion {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.aurora.codes/v1/genius/search/%@", term]];
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
        if (error) {
            completion(nil);
            return;
        }

        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            completion(nil);
            return;
        }

        NSString* geniusSongUrl = json[@"text"];
        if (geniusSongUrl) {
            completion([NSURL URLWithString:geniusSongUrl]);
        } else {
            completion(nil);
        }
    }];

    [task resume];
}
@end
