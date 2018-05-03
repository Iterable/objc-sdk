//
//  IterableAction.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableAction.h"

NSString *const IterableActionTypeDismiss    = @"dismiss";
NSString *const IterableActionTypeOpen       = @"open";
NSString *const IterableActionTypeDeeplink   = @"deeplink";
NSString *const IterableActionTypeTextInput  = @"textInput";

@interface IterableAction ()

@property(nonatomic, readonly) NSDictionary *config;

@end

@implementation IterableAction

+ (instancetype)actionFromDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _config = dictionary;
    }
    return self;
}

- (NSString *)type {
    return self.config[@"type"];
}

- (NSString *)data {
    return self.config[@"data"];
}

- (NSString *)inputTitle {
    return self.config[@"inputTitle"];
}

- (NSString *)inputPlaceholder {
    return self.config[@"inputPlaceholder"];
}

- (BOOL)isOfType:(NSString *)type {
    return [self.type isEqualToString:type];
}

@end
