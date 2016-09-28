//
//  IterableInAppManager.h
//  Pods
//
//  Created by David Truong on 9/14/16.
//
//

#import <UIKit/UIKit.h>

@interface IterableInAppManager : NSObject

/**
 An array of action objects representing the actions that the user can take in response to the alert view
 */
@property (nonatomic, readonly) NSArray *actions;

+(void) showNotification:(NSString *)type callbackBlock:(void (^)(NSString*))callbackBlock;

@end
