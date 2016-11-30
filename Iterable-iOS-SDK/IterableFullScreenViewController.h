//
//  IterableFullScreenViewController.h
//
//  Created by David Truong on 8/24/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IterableInAppBaseViewController.h"

@interface IterableFullScreenViewController : IterableInAppBaseViewController

@property (nonatomic, strong) UILabel* Title;
@property (nonatomic, strong) UILabel* TextBody;
@property (nonatomic, strong) UIStackView* DialogButtons;

@property (nonatomic) NSString *imageURL;
@property (nonatomic) int backgroundColor;

@property (nonatomic) NSString *titleFontName;
@property (nonatomic) int titleColor;
@property (nonatomic) NSString *titleString;

@property (nonatomic) NSString *bodyTextFontName;
@property (nonatomic) int bodyTextColor;
@property (nonatomic) NSString *bodyTextString;

- (void) setData:(NSDictionary *)jsonPayload;

@end
 
