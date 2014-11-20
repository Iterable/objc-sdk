//
//  Iterable_API.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Iterable_iOS_SDK_IterableAPI_h
#define Iterable_iOS_SDK_IterableAPI_h

@interface IterableAPI : NSObject

- (id) initWithApiKey:(NSString*)apiKey andEmail:(NSString*) email;

@end

#endif
