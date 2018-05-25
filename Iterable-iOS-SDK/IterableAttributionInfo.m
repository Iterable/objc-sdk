//
//  IterableAttributionInfo.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/24/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableAttributionInfo.h"

@implementation IterableAttributionInfo

- (instancetype)initWithCampaignId:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId {
    self = [self init];
    if (self) {
        _campaignId = campaignId;
        _templateId = templateId;
        _messageId = messageId;
    }
    return self;
}

@end
