//
//  IterableAction.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const IterableActionTypeDismiss;
extern NSString *const IterableActionTypeOpen;
extern NSString *const IterableActionTypeDeeplink;
extern NSString *const IterableActionTypeTextInput;

@interface IterableAction : NSObject

@property(nonatomic, readonly) NSString *type;
@property(nonatomic, readonly) NSString *data;

// Optional fields
@property(nonatomic, readonly) NSString *inputTitle;
@property(nonatomic, readonly) NSString *inputPlaceholder;
@property(nonatomic, readwrite) NSString *userInput;

+ (instancetype)actionFromDictionary:(NSDictionary *)dictionary;
- (BOOL)isOfType:(NSString *)type;

@end
