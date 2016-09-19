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
    
    NSLog(@"actionString: %@", actionString);
    //setup call to IterableInAppManager to handle broadcast
    
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
