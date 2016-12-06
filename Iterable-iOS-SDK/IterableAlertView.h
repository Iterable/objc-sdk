//
//  IterableAlertView.h
//  Iterable-iOS-SDK

//  Implementation based of of NYAlert created by Nealon Young
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IterableAlertViewButtonType) {
    IterableAlertViewButtonTypeFilled,
    IterableAlertViewButtonTypeBordered
};

typedef NS_ENUM(NSUInteger, IterableInAppNotificationLocation) {
    NotifLocationCenter,
    NotifLocationBottom,
    NotifLocationTop,
    NotifLocationFull
};

@interface UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface IterableAlertViewButton : UIButton

@property (nonatomic) IterableAlertViewButtonType type;

@property (nonatomic) CGFloat cornerRadius;

@end

@interface IterableAlertView : UIView

- (void)setLocation:(IterableInAppNotificationLocation)location;
- (void)setStylePopUpDialog;
- (void)updateHorizontalConstraint;

@property UILabel *titleLabel;
@property UITextView *messageTextView;
@property (nonatomic) UIView *contentView;

@property (nonatomic) UIFont *buttonTitleFont;
@property (nonatomic) UIFont *cancelButtonTitleFont;
@property (nonatomic) UIFont *destructiveButtonTitleFont;

@property (nonatomic) UIColor *buttonColor;
@property (nonatomic) UIColor *buttonTitleColor;
@property (nonatomic) UIColor *cancelButtonColor;
@property (nonatomic) UIColor *cancelButtonTitleColor;
@property (nonatomic) UIColor *destructiveButtonColor;
@property (nonatomic) UIColor *destructiveButtonTitleColor;

@property (nonatomic) CGFloat buttonCornerRadius;

@property (nonatomic) CGFloat maximumWidth;

@property (nonatomic, readonly) UIView *alertBackgroundView;

@property (nonatomic, readonly) NSLayoutConstraint *backgroundViewVerticalCenteringConstraint;

@property (nonatomic) NSArray *actionButtons;

@property (nonatomic) NSArray *textFields;

@end
