//
//  IterableDeeplink.h
//  Pods
//
//  Created by David Truong on 11/16/17.
//
//


#import "IterableConstants.h"

@interface IterableDeeplinkManager : NSObject

/**
 @method
 
 @abstract a singleton of IterableDeeplinkManager
 */
+(instancetype)instance;

/*!
 @method
 
 @abstract tracks a link click and passes the redirected URL to the callback
 
 @param webpageURL      the URL that was clicked
 @param callbackBlock   the callback to send after the webpageURL is called
 
 @discussion            passes the string of the redirected URL to the callback
 */
-(void) getAndTrackDeeplink:(NSURL *)webpageURL callbackBlock:(ITEActionBlock)callbackBlock;

/**
 * Checks if the URL looks like a link rewritten by Iterable
 * @param url the URL to check
 * @return YES if it looks like a link rewritten by Iterable, NO otherwise
 */
- (BOOL)isIterableDeeplink:(NSURL *)url;

@end
