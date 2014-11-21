//
//  Iterable_API.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 11/19/14.
//  Copyright (c) 2014 Iterable. All rights reserved.
//

@import Foundation;

@interface IterableAPI : NSObject

- (id) initWithApiKey:(NSString *)apiKey andEmail:(NSString *) email;

- (void)getUser;
- (void)registerToken:(NSData *)token;

@end
