//
//  IterableAttributionInfo.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 5/24/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableAttributionInfo.h"

@implementation IterableAttributionInfo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_campaignId forKey:@"campaignId"];
    [aCoder encodeObject:_templateId forKey:@"templateId"];
    [aCoder encodeObject:_messageId forKey:@"messageId"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self) {
        _campaignId = [coder decodeObjectForKey:@"campaignId"];
        _templateId = [coder decodeObjectForKey:@"templateId"];
        _messageId = [coder decodeObjectForKey:@"messageId"];
    }
    return self;
}

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
