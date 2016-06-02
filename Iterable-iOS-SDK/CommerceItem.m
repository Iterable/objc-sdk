//
//  CommerceItem.m
//  Iterable-iOS-SDK
//
//  Created by Girish Sastry on 3/23/15.
//  Copyright (c) 2015 Iterable. All rights reserved.
//

@import Foundation;
#import "CommerceItem.h"

@interface CommerceItem () {
}
@end

@implementation CommerceItem {
    
}

- (id)initWithId:(nonnull NSString *)id name:(nonnull NSString *)name price:(nonnull NSNumber *)price quantity:(NSUInteger)quantity
{
    if (self = [super init]) {
        _id = id;
        _name = name;
        _price = price;
        _quantity = quantity;
    }
    return self;
}




@end