//
//  IterableUtil.h
//  Iterable-iOS-SDK
//
//  Created by Tapash Majumder on 5/29/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

// all params are nonnull, unless annotated otherwise
NS_ASSUME_NONNULL_BEGIN

/*!
 @abstract Iterable Utility class.
 */
@interface IterableUtil : NSObject

/*!
 @abstract Get the singleton shared instance.
 */
+ (IterableUtil *)sharedInstance;

/*!
 @abstract Get/Set the currentDate. If set to nil, it will return the System date.
 We should replace any call to [NSDate date] with this so that we can mock past/future dates.
 */
@property (copy) NSDate * _Nullable currentDate;

@end

NS_ASSUME_NONNULL_END
