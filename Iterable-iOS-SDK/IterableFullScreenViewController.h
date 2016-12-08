//
//  IterableFullScreenViewController.h
//  Iterable-iOS-SDK

//  Created by David Truong on 8/24/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IterableInAppBaseViewController.h"

@interface IterableFullScreenViewController : IterableInAppBaseViewController

/**
 @method
 
 @abstract Sets the data for the viewController
 
 @param jsonPayload the payload data
 */
- (void) ITESetData:(NSDictionary *)jsonPayload;

@end
 
