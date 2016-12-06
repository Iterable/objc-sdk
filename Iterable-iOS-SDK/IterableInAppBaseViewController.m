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

@interface IterableInAppBaseViewController ()

-(void)setData:(NSDictionary *)jsonPayload;

@property (nonatomic) NSMutableArray *actionButtonsMapping;

@end

@implementation IterableInAppBaseViewController

actionBlock customBlockCallback;

// documented in IterableInAppBaseViewController.h
-(void)actionButtonClicked:(UIButton *)sender {
    NSString *actionString = _actionButtonsMapping[sender.tag];
    
    if (customBlockCallback != nil && ![actionString isEqualToString:@""]) {
        //TODO: add in click tracking
        IterableAPI *api = IterableAPI.sharedInstance;
        [api track:actionString];
        customBlockCallback(actionString);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// documented in IterableInAppBaseViewController.h
-(void)addActionButton:(NSInteger)id actionString:(NSString *)actionString {
    if (_actionButtonsMapping == NULL)
    {
        _actionButtonsMapping = [NSMutableArray array];
    }
    if (actionString != nil) {
        _actionButtonsMapping[id] = actionString;
    }
}

// documented in IterableInAppBaseViewController.h
-(void)setCallback:(actionBlock)callbackBlock {
    customBlockCallback = callbackBlock;
}

// documented in IterableInAppBaseViewController.h
-(void)setData:(NSDictionary *)jsonPayload {
    NSLog(@"setData on IterableInAppBaseViewController should not be called directly");
}

@end
