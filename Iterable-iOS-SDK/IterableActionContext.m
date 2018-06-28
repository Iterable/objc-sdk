//
// Created by Victor Babenko on 6/27/18.
// Copyright (c) 2018 Iterable. All rights reserved.
//

#import "IterableActionContext.h"


@implementation IterableActionContext

- (instancetype)initWithAction:(IterableAction *)action source:(IterableActionSource)source {
    self = [super init];
    if (self) {
        _action = action;
        _source = source;
    }
    return self;
}

+ (instancetype)contextWithAction:(IterableAction *)action source:(IterableActionSource)source {
    return [[IterableActionContext alloc] initWithAction:action source:source];
}

@end