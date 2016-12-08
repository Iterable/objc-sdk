//
//  IterableAlertView.h
//  Iterable-iOS-SDK

//  Implementation based of of NYAlert created by Nealon Young
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 ENUM specifying the type of button
*/
typedef NS_ENUM(NSUInteger, IterableAlertViewButtonType) {
    /** Filled Button View */
    IterableAlertViewButtonTypeFilled,
    /** Bordered Button View */
    IterableAlertViewButtonTypeBordered
};

/**
 ENUM specifying the location to display the InApp Notification
 */
typedef NS_ENUM(NSUInteger, IterableInAppNotificationLocation) {
    /** Location Center */
    NotifLocationCenter,
    /** Location Bottom */
    NotifLocationBottom,
    /** Location Top */
    NotifLocationTop,
    /** Location Full Screen */
    NotifLocationFull
};

@interface UIButton (BackgroundColor)

/**
 @abstract Sets the InApp button background color
 
 @param color The UIcolor
 @param state The state of the button
 */
- (void)ITESetButtonBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface IterableAlertViewButton : UIButton

@property (nonatomic) IterableAlertViewButtonType type;

@property (nonatomic) CGFloat cornerRadius;

@end

@interface IterableAlertView : UIView

/**
 @method
 
 @abstract sets the location the InApp notification is displayed at
 
 @param location the location to display the notification
 */
- (void)setInAppLocation:(IterableInAppNotificationLocation)location;

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
