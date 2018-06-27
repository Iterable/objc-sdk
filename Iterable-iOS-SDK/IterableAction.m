//
//  IterableAction.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/1/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableAction.h"

NSString *const IterableActionTypeOpenUrl    = @"openUrl";

@interface IterableAction ()

@property(nonatomic, readonly) NSDictionary *config;

@end

@implementation IterableAction

+ (instancetype)actionFromDictionary:(NSDictionary *)dictionary {
    if (dictionary != nil) {
        return [[self alloc] initWithDictionary:dictionary];
    } else {
        return nil;
    }
}

+ (instancetype)actionOpenUrl:(NSString *)url {
    if (url != nil) {
        return [self actionFromDictionary:@{@"type": IterableActionTypeOpenUrl, @"data": url}];
    } else {
        return nil;
    }
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

- (BOOL)isOfType:(NSString *)type {
    return [self.type isEqualToString:type];
}

@end
