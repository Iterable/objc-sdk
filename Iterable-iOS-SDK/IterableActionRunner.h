//
//  IterableActionRunner.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IterableAction.h"
#import "IterableActionContext.h"

@interface IterableActionRunner : NSObject

+ (BOOL)executeAction:(IterableAction *)action from:(IterableActionSource)source;

@end
