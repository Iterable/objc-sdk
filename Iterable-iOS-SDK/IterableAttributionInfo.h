//
//  IterableAttributionInfo.h
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/24/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IterableAttributionInfo : NSObject<NSCoding>

@property (nonatomic, readonly, copy) NSNumber *campaignId;
@property (nonatomic, readonly, copy) NSNumber *templateId;
@property (nonatomic, readonly, copy) NSString *messageId;

- (instancetype)initWithCampaignId:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId;

@end
