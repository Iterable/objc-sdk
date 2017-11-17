//
//  IterableDeeplink.m
//  Pods
//
//  Created by David Truong on 11/16/17.
//
//

#import <Foundation/Foundation.h>
#import "IterableDeeplinkManager.h"
#import "IterableConstants.h"

@interface IterableDeeplinkManager () <NSURLSessionDelegate>
@end

@implementation IterableDeeplinkManager {
}

// the URL session we're going to be using
static IterableDeeplinkManager *deeplinkManager;
NSURLSession *redirectUrlSession;
NSString *deepLinkLocation;

// documented in IterableDeeplinkManager.h
+(instancetype)instance
{
    if (deeplinkManager == nil) {
        deeplinkManager = [[IterableDeeplinkManager alloc] init];
    }
    return deeplinkManager;
}

/**
 @method
 
 @abstract creates an instance of IterableDeeplinkManager and redirectUrlSession
 */
- (instancetype)init {
    self = [super init];
    [self createRedirectUrlSession];
    return self;
}

// documented in IterableDeeplinkManager.h
-(void)getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ITBL_DEEPLINK_IDENTIFIER options:0 error:NULL];
    NSString *urlString = webpageURL.absoluteString;
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    
    if (match == NULL) {
        callbackBlock(webpageURL.absoluteString);
    } else {
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

/**
 @method
 
 @param session the session
 @param task the task
 @param redirectResponse the redirectResponse
 @param request the request
 @param completionHandler the completionHandler
 
 @abstract delegate handler when a redirect occurs. Stores a reference to the redirect url and does not execute the redirect.
 */
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
