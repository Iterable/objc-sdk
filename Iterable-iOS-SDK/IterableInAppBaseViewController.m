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

@property (nonatomic) NSMutableArray *actionButtonsMapping;

@end

@implementation IterableInAppBaseViewController

actionBlock customBlockCallback;

-(void)actionButtonClicked:(UIButton *)sender {
    NSString *actionString = _actionButtonsMapping[sender.tag];
    
    //TODO: track the inApp button click here
    
    if (customBlockCallback != nil) {
        customBlockCallback(actionString);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addActionButton:(NSInteger)id actionString:(NSString *)actionStringValue {
    if (_actionButtonsMapping == NULL)
    {
        _actionButtonsMapping = [NSMutableArray array];
    }
    _actionButtonsMapping[id] = actionStringValue;
}

-(void)setCallback:(actionBlock)callbackBlock {
    customBlockCallback = callbackBlock;
}

@end
