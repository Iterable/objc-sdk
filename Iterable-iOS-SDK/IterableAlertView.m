//
//  IterableAlertView.m
//
//  Implementation based of of NYAlert created by Nealon Young
//  Copyright (c) 2015 Nealon Young. All rights reserved.
//

#import "IterableAlertView.h"

#import "IterableAlertViewController.h"

@interface IterableAlertTextView : UITextView

@end

@implementation IterableAlertTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    
    self.textContainerInset = UIEdgeInsetsZero;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize])) {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize {
    if ([self.text length]) {
        return self.contentSize;
    } else {
        return CGSizeZero;
    }
}

@end

@implementation UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    [self setBackgroundImage:[self imageWithColor:color] forState:state];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation IterableAlertViewButton

+ (id)buttonWithType:(UIButtonType)buttonType {
    return [super buttonWithType:UIButtonTypeCustom];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;
    
    self.layer.borderWidth = 1.0f;
    
    self.cornerRadius = 0.0f;
    self.clipsToBounds = YES;
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    [self tintColorDidChange];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self invalidateIntrinsicContentSize];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if (self.type == IterableAlertViewButtonTypeFilled) {
        if (self.enabled) {
            [self setBackgroundColor:self.tintColor];
        }
    } else {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    
    self.layer.borderColor = self.tintColor.CGColor;
    
    [self setNeedsDisplay];
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGSize)intrinsicContentSize {
    if (self.hidden) {
        return CGSizeZero;
    }
    
    return CGSizeMake([super intrinsicContentSize].width + 12.0f, 30.0f);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.layer.borderColor = self.tintColor.CGColor;
    
    if (self.type == IterableAlertViewButtonTypeBordered) {
        self.layer.borderWidth = 1.0f;
    } else {
        self.layer.borderWidth = 0.0f;
    }
    
    if (self.state == UIControlStateHighlighted) {
        self.layer.backgroundColor = self.tintColor.CGColor;
        //[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    } else {
        if (self.type == IterableAlertViewButtonTypeBordered) {
            self.layer.backgroundColor = nil;
            [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        } else {
            //[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

@end

@interface IterableAlertView ()

@property (nonatomic) NSLayoutConstraint *alertBackgroundWidthConstraint;
@property (nonatomic) UIView *contentViewContainerView;
@property (nonatomic) UIView *textFieldContainerView;
@property (nonatomic) UIView *actionButtonContainerView;
@property (nonatomic) CGFloat alertBackgroundViewWidth;

@end

@implementation IterableAlertView

-(BOOL)shouldAutorotate {
    // Preparations to rotate view go here
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // or however you want to rotate
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
        CGFloat screenWidth = screenSize.width;
        
        self.maximumWidth = screenWidth;
        
        _alertBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.alertBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.alertBackgroundView.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        [self addSubview:_alertBackgroundView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = NSLocalizedString(@"", nil);
        [self.alertBackgroundView addSubview:self.titleLabel];
        
        _messageTextView = [[IterableAlertTextView alloc] initWithFrame:CGRectZero];
        [self.messageTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.messageTextView.backgroundColor = [UIColor clearColor];
        [self.messageTextView setContentHuggingPriority:0 forAxis:UILayoutConstraintAxisVertical];
        [self.messageTextView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        self.messageTextView.editable = NO;
        self.messageTextView.textAlignment = NSTextAlignmentCenter;
        self.messageTextView.textColor = [UIColor blackColor];
        self.messageTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.messageTextView.text = NSLocalizedString(@"", nil);
        [self.alertBackgroundView addSubview:self.messageTextView];
        
        _contentViewContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentViewContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.contentViewContainerView];
        
        _textFieldContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.textFieldContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.textFieldContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.textFieldContainerView];
        
        _actionButtonContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.actionButtonContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.actionButtonContainerView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.alertBackgroundView addSubview:self.actionButtonContainerView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        _alertBackgroundViewWidth = MIN(CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds),
                                        CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)) * 0.8f;
        
        if (_alertBackgroundViewWidth > self.maximumWidth) {
            _alertBackgroundViewWidth = self.maximumWidth;
        }
        
        _alertBackgroundWidthConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:_alertBackgroundViewWidth];
  
        [self addConstraint:self.alertBackgroundWidthConstraint];
 
        _backgroundViewVerticalCenteringConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                  attribute:NSLayoutAttributeCenterY
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterY
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
        
        [self addConstraint:self.backgroundViewVerticalCenteringConstraint];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleLabel]-|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(_titleLabel)]];
        
        [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_messageTextView]-|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(_messageTextView)]];
        
        [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentViewContainerView]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(_contentViewContainerView)]];
        
        [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textFieldContainerView]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(_textFieldContainerView)]];
        
        [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_actionButtonContainerView]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(_actionButtonContainerView)]];
        
        [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_titleLabel]-2-[_contentViewContainerView][_messageTextView][_textFieldContainerView]-2-[_actionButtonContainerView]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(_titleLabel,
                                                                                                                                _messageTextView,
                                                                                                                                _contentViewContainerView,
                                                                                                                                _textFieldContainerView,
                                                                                                                                _actionButtonContainerView)]];
    }
    
    return self;
}

// Pass through touches outside the backgroundView for the presentation controller to handle dismissal
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview hitTest:[self convertPoint:point toView:subview] withEvent:event]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setMaximumWidth:(CGFloat)maximumWidth {
    _maximumWidth = maximumWidth;
    self.alertBackgroundWidthConstraint.constant = maximumWidth;
}

- (void)updateHorizontalConstraint {
    [self removeConstraint:self.alertBackgroundWidthConstraint];
    
    _alertBackgroundViewWidth = CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds);
    
    if (_alertBackgroundViewWidth > self.maximumWidth) {
        _alertBackgroundViewWidth = self.maximumWidth;
    }
    
    _alertBackgroundWidthConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:_alertBackgroundViewWidth];
    
    [self addConstraint:self.alertBackgroundWidthConstraint];
    
    
}


- (void)setContentView:(UIView *)contentView {
    [self.contentView removeFromSuperview];
    
    _contentView = contentView;
    
    if (contentView) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentViewContainerView addSubview:self.contentView];
        
        [self.contentViewContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                                              options:0
                                                                                              metrics:nil
                                                                                                views:NSDictionaryOfVariableBindings(_contentView)]];
        
        [self.contentViewContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_contentView]-|"
                                                                                              options:0
                                                                                              metrics:nil
                                                                                                views:NSDictionaryOfVariableBindings(_contentView)]];
    }
}

- (void)setTextFields:(NSArray *)textFields {
    for (UITextField *textField in self.textFields) {
        [textField removeFromSuperview];
    }
    
    _textFields = textFields;
    
    for (int i = 0; i < [textFields count]; i++) {
        UITextField *textField = textFields[i];
        [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.textFieldContainerView addSubview:textField];
        
        [self.textFieldContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textField]-|"
                                                                                            options:0
                                                                                            metrics:nil
                                                                                              views:NSDictionaryOfVariableBindings(textField)]];
        
        // Pin the first text field to the top of the text field container view
        if (i == 0) {
            [self.textFieldContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textField]"
                                                                                                options:0
                                                                                                metrics:nil
                                                                                                  views:NSDictionaryOfVariableBindings(_contentViewContainerView, textField)]];
        } else {
            UITextField *previousTextField = textFields[i - 1];
            
            [self.textFieldContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousTextField]-[textField]"
                                                                                                options:0
                                                                                                metrics:nil
                                                                                                  views:NSDictionaryOfVariableBindings(previousTextField, textField)]];
        }
        
        // Pin the final text field to the bottom of the text field container view
        if (i == ([textFields count] - 1)) {
            [self.textFieldContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textField]|"
                                                                                                options:0
                                                                                                metrics:nil
                                                                                                  views:NSDictionaryOfVariableBindings(textField)]];
        }
    }
}

- (void)setActionButtons:(NSArray *)actionButtons {
    for (UIButton *button  in self.actionButtons) {
        [button removeFromSuperview];
    }
    
    _actionButtons = actionButtons;
    
    // If there are 2 actions, display the buttons next to each other. Otherwise, stack the buttons vertically at full width
    if ([actionButtons count] == 2) {
        UIButton *firstButton = actionButtons[0];
        UIButton *lastButton = actionButtons[1];
        
        [self.actionButtonContainerView addSubview:firstButton];
        [self.actionButtonContainerView addSubview:lastButton];
        
        [self.actionButtonContainerView addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:lastButton
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f]];
        
        [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[firstButton][lastButton]|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(firstButton, lastButton)]];
        
        [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[firstButton(40)]|"
                                                                                               options:0
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(_contentViewContainerView, firstButton)]];
        
        [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastButton(40)]"
                                                                                               options:0
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(lastButton)]];
    } else {
        for (int i = 0; i < [actionButtons count]; i++) {
            UIButton *actionButton = actionButtons[i];
            
            [self.actionButtonContainerView addSubview:actionButton];
            
            [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[actionButton]|"
                                                                                                   options:0
                                                                                                   metrics:nil
                                                                                                     views:NSDictionaryOfVariableBindings(actionButton)]];
            
            [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[actionButton(40)]"
                                                                                                   options:0
                                                                                                   metrics:nil
                                                                                                     views:NSDictionaryOfVariableBindings(actionButton)]];
            
            if (i == 0) {
                [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[actionButton]"
                                                                                                       options:0
                                                                                                       metrics:nil
                                                                                                         views:NSDictionaryOfVariableBindings(_contentViewContainerView, actionButton)]];
            } else {
                UIButton *previousButton = actionButtons[i - 1];
                
                [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousButton]-[actionButton]"
                                                                                                       options:0
                                                                                                       metrics:nil
                                                                                                         views:NSDictionaryOfVariableBindings(previousButton, actionButton)]];
            }
            
            if (i == ([actionButtons count] - 1)) {
                [self.actionButtonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[actionButton]|"
                                                                                                       options:0
                                                                                                       metrics:nil
                                                                                                         views:NSDictionaryOfVariableBindings(actionButton)]];
            }
        }
    }
}

- (void)setLocation:(IterableInAppNotificationLocation)location {
    if (location == NotifLocationTop) {
        [self removeConstraint:self.backgroundViewVerticalCenteringConstraint];
        _backgroundViewVerticalCenteringConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                  attribute:NSLayoutAttributeTop
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeTop
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
        [self addConstraint:self.backgroundViewVerticalCenteringConstraint];
    } else if (location == NotifLocationBottom) {
        [self removeConstraint:self.backgroundViewVerticalCenteringConstraint];
        _backgroundViewVerticalCenteringConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
        [self addConstraint:self.backgroundViewVerticalCenteringConstraint];
    } else if (location == NotifLocationFull) {
        [self setStyleFullScreen];
    } else {
        //Centered by defaualt
        [self setStylePopUpDialog];
    }
    
    
}

- (void)setStyleFullScreen {
    
    [self removeConstraint:self.backgroundViewVerticalCenteringConstraint];
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0f
                                                       constant:0.0f
                          ]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1.0f
                                                       constant:0.0f
                          ]];
 
    [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_titleLabel]-2-[_contentViewContainerView(200)]-2-[_messageTextView][_textFieldContainerView][_actionButtonContainerView]-20-|"
                                                     options:0
                                                     metrics:nil
                                                     views:NSDictionaryOfVariableBindings(_titleLabel,
                                                                                          _messageTextView,
                                                                                          _contentViewContainerView,
                                                                                          _textFieldContainerView,
                                                                                          _actionButtonContainerView)]];
    
    NSDictionary *localMetrics = @{
                              @"width" : @(_alertBackgroundViewWidth)
                              };
    
    [self.alertBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[_contentViewContainerView(width)]-(>=20)-|"
                                                                                     options:0
                                                                                     metrics:localMetrics
                                                                                       views:NSDictionaryOfVariableBindings(_contentViewContainerView)]];
    
    _contentViewContainerView.center = self.alertBackgroundView.center;
    
    /*[self.alertBackgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_contentViewContainerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.alertBackgroundView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];*/

 }

- (void)setStylePopUpDialog {
    [self removeConstraint:self.alertBackgroundWidthConstraint];
        _alertBackgroundWidthConstraint = [NSLayoutConstraint constraintWithItem:self.alertBackgroundView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0.0f
                                                                        constant:_alertBackgroundViewWidth * .8];

    [self addConstraint:self.alertBackgroundWidthConstraint];
}


@end
