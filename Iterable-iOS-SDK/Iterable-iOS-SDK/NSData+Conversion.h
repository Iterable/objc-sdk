//
//  NSData+Conversion.h
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 2/6/15.
//  Copyright (c) 2015 Iterable. All rights reserved.
//

#ifndef Iterable_iOS_SDK_NSData_Conversion_h
#define Iterable_iOS_SDK_NSData_Conversion_h

// http://stackoverflow.com/questions/1305225/best-way-to-serialize-a-nsdata-into-an-hexadeximal-string

// If this is part of a static library, you need to add -all_load to the Other Linker Flags build setting.
// http://stackoverflow.com/questions/3998483/objective-c-category-causing-unrecognized-selector

#import <Foundation/Foundation.h>

@interface NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString;

@end

#endif
