//
//  IterableActionRunner.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IterableAction.h"

@interface IterableActionRunner : NSObject

+ (void)executeAction:(IterableAction *)action;

@end
