//
//  IterableInAppBaseViewController.h
//  Iterable-iOS-SDK
//
//  Created by David Truong on 9/19/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IterableInAppBaseViewController : UIViewController

typedef void (^actionBlock)(NSString *);

-(void)actionButtonClicked:(UIButton *)sender;
-(void)addActionButton:(NSInteger)id actionString:(NSString *)actionStringValue;
-(void)setCallback:(actionBlock)callbackBlock;

@end
