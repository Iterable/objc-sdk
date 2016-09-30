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

@interface IterableInAppBaseViewController ()

-(void)setData:(NSDictionary *)jsonPayload;

@property (nonatomic) NSMutableArray *actionButtonsMapping;

@end

@implementation IterableInAppBaseViewController

actionBlock customBlockCallback;

-(void)actionButtonClicked:(UIButton *)sender {
    NSString *actionString = _actionButtonsMapping[sender.tag];
    
    if (customBlockCallback != nil && ![actionString isEqualToString:@""]) {
        //TODO: add in click tracking
        customBlockCallback(actionString);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addActionButton:(NSInteger)id actionString:(NSString *)actionStringValue {
    if (_actionButtonsMapping == NULL)
    {
        _actionButtonsMapping = [NSMutableArray array];
    }
    if (actionStringValue != nil) {
        _actionButtonsMapping[id] = actionStringValue;
    }
}

-(void)setCallback:(actionBlock)callbackBlock {
    customBlockCallback = callbackBlock;
}

-(void)setData:(NSDictionary *)jsonPayload {
    NSLog(@"setData on IterableInAppBaseViewController should not be called directly");
}

@end
