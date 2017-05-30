//
//  IterableInAppBaseViewController.m
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/19/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import "IterableInAppBaseViewController.h"
#import "IterableConstants.h"
#import "IterableInAppManager.h"
#import "IterableAPI.h"
#import "IterableNotificationMetadata.h"

@interface IterableInAppBaseViewController ()

// documented in IterableInAppBaseViewController.h
-(void)ITESetData:(NSDictionary *)jsonPayload;

@property (nonatomic) NSMutableArray *actionButtonsMapping;
@property IterableNotificationMetadata *trackParams;

@end

@implementation IterableInAppBaseViewController

ITEActionBlock customBlockCallback;

// documented in IterableInAppBaseViewController.h
-(void)ITEActionButtonClicked:(UIButton *)sender {
    NSString *actionString = _actionButtonsMapping[sender.tag];
    IterableAPI *api = IterableAPI.sharedInstance;
    
    if (_trackParams != nil) {
        NSNumber *buttonId = @(sender.tag);
        [api trackInAppClick:_trackParams.campaignId messageId:_trackParams.messageId buttonIndex:buttonId];
    }
    
    if (customBlockCallback != nil && ![actionString isEqualToString:@""]) {
        customBlockCallback(actionString);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// documented in IterableInAppBaseViewController.h
-(void)ITEAddActionButton:(NSInteger)id actionString:(NSString *)actionString {
    if (_actionButtonsMapping == NULL)
    {
        _actionButtonsMapping = [NSMutableArray array];
    }
    if (actionString != nil) {
        _actionButtonsMapping[id] = actionString;
    }
}

// documented in IterableInAppBaseViewController.h
-(void)ITESetCallback:(ITEActionBlock)callbackBlock {
    customBlockCallback = callbackBlock;
}

// documented in IterableInAppBaseViewController.h
-(void)ITESetData:(NSDictionary *)jsonPayload {
    NSLog(@"ITESetData on IterableInAppBaseViewController should not be called directly");
}

// documented in IterableInAppBaseViewController.h
-(void)ITESetTrackParams:(IterableNotificationMetadata *)params {
    _trackParams = params;
}

@end
