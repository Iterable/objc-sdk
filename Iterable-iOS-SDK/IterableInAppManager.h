//
//  IterableInAppManager.h
//  Pods
//
//  Created by David Truong on 9/14/16.
//
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue & 0xFF)))/255.0 alpha:1.0]

@interface IterableInAppManager : NSObject

/**
 An array of action objects representing the actions that the user can take in response to the alert view
 */
@property (nonatomic, readonly) NSArray *actions;

typedef void (^actionBlock)(NSString *);

+(void) showNotification:(NSDictionary *)dialogOptions;

+(void) showNotification:(NSString *)type callbackBlock:(actionBlock)callbackBlock;

+(int) getIntColorFromKey:(NSDictionary*)payload keyString:(NSString*)keyString;

+ (UIColor *)colorWithHexString:(NSString *)str;

@end
