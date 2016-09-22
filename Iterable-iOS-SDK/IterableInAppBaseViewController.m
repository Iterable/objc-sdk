//
//  IterableInAppBaseViewController.m
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/19/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import "IterableInAppBaseViewController.h"
#import "IterableConstants.h"

@interface IterableInAppBaseViewController ()

//todo use these
@property (nonatomic) NSMutableArray *actionButtonsMapping;

@end

@implementation IterableInAppBaseViewController

-(void)actionButtonClicked:(UIButton *)sender {
    //call central call backs here
    NSString *actionString = _actionButtonsMapping[sender.tag];
    NSDictionary *info = @{ ITERABLE_IN_APP_ACTION : actionString };
    [[NSNotificationCenter defaultCenter] postNotificationName:ITERABLE_IN_APP_ACTION object:nil userInfo:info];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addActionButton:(NSInteger)id actionString:(NSString *)actionStringValue {
    if (_actionButtonsMapping == NULL)
    {
        _actionButtonsMapping = [NSMutableArray array];
    }
    _actionButtonsMapping[id] = actionStringValue;
}
@end
