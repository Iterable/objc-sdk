//
//  CommerceItem.h
//  Iterable-iOS-SDK
//
//  Created by Girish Sastry on 3/23/15.
//  Copyright (c) 2015 Iterable. All rights reserved.
//

@import Foundation;

// all params are nonnull, unless annotated otherwise
NS_ASSUME_NONNULL_BEGIN

/**
 `CommerceItem` represents a product. These are used by the commerce API; see [IterableAPI trackPurchase:items:dataFields:]
 */
@interface CommerceItem : NSObject

////////////////////
/// @name Properties
////////////////////

/** id of this product */
@property (nonatomic, readwrite, strong) NSString *id;

/** name of this product */
@property (nonatomic, readwrite, strong) NSString *name;

/** price of this product */
@property (nonatomic, readwrite, strong) NSNumber *price;

/** quantity of this product */
@property (nonatomic, readwrite) NSUInteger quantity;

/////////////////////
/// @name Constructor
/////////////////////

/**
 @method
 
 @abstract Creates a `CommerceItem` with the specified properties
 
 @param id          id of the product
 @param name        name of the product
 @param price       price of the product
 @param quantity    quantity of the product
 
 @return an instance of `CommerceItem` with the specified properties
 */
- (id)initWithId:(NSString *)id name:(NSString *)name price:(NSNumber *)price quantity:(NSUInteger)quantity;

/**
 @method
 
 @abstract A Dictionary respresentation of this item
 
 @return An NSDictionary representing this item
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
