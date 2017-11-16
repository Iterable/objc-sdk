//
//  IterableDeeplink.m
//  Pods
//
//  Created by David Truong on 11/16/17.
//
//

#import <Foundation/Foundation.h>
#import "IterableDeeplink.h"
#import "IterableConstants.h"

@interface IterableDeeplink () <NSURLSessionDelegate>
@end

@implementation IterableDeeplink {
}

// the URL session we're going to be using
static NSURLSession *redirectUrlSession = nil;
NSString *deepLinkLocation = nil;

// documented in IterableAPI.h
-(void) getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ITBL_DEEPLINK_IDENTIFIER options:0 error:NULL];
    NSString *urlString = webpageURL.absoluteString;
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    
    if (match == NULL) {
        callbackBlock(webpageURL.absoluteString);
    } else {
        if (redirectUrlSession == nil) {
            [self createRedirectUrlSession];
        }
        NSURLSessionDataTask *trackAndRedirectTask = [redirectUrlSession
                                                      dataTaskWithURL:webpageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          callbackBlock(deepLinkLocation);
                                                      }];
        [trackAndRedirectTask resume];
    }
}

/**
 @method
 
 @abstract creates a singleton URLSession for the class to use
 */
- (void)createRedirectUrlSession
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        redirectUrlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
}


//////////////////////////////////////////////////////////////
/// @name NSURLSessionDelegate Functions
//////////////////////////////////////////////////////////////


- (void)URLSession:(NSURLSession *)session
        task:(NSURLSessionTask *)task
        willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse
        newRequest:(NSURLRequest *)request
        completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    deepLinkLocation = request.URL.absoluteString;
    completionHandler(nil);
}

@end
