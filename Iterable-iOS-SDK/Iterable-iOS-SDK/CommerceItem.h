//
//  CommerceItem.h
//  Iterable-iOS-SDK
//
//  Created by Girish Sastry on 3/23/15.
//  Copyright (c) 2015 Iterable. All rights reserved.
//

@import Foundation;
#import "JSONModel.h"

@interface CommerceItem : JSONModel

//@property (nonatomic) NSString *sku;          // optional
//@property (nonatomic) NSString *description;          // optional
//@property (nonatomic) NSArray *categories;          // optional, array of strings

//@property (nonatomic) NSString *imageUrl;
//@property (nonatomic) NSString *url;
//@property (nonatomic) NSDictionary *dataFields;

@property (nonatomic, readwrite, strong) NSString *id;
@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSNumber *price;
@property (nonatomic, readwrite) NSUInteger quantity;

- (id)initWithId:(NSString *)id name:(NSString *)name price:(NSNumber *)price quantity:(NSUInteger)quantity;

@end
