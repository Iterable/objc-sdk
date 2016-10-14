//
//  IterableFullScreenViewController.m
//
//  Created by David Truong on 8/24/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import "IterableFullScreenViewController.h"
#import "IterableConstants.h"
#import "IterableInAppManager.h"

@interface IterableFullScreenViewController ()
@property (nonatomic, strong) UIImageView* ImageView;
@property (nonatomic) NSDictionary *actionButtons;

@end

@implementation IterableFullScreenViewController

CGFloat imageWidth =0;
CGFloat imageHeight =0;

NSDictionary *inAppPayload;

-(void)setData:(NSDictionary *)jsonPayload {
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_TITLE]) {
        NSDictionary* title = [jsonPayload objectForKey:ITERABLE_IN_APP_TITLE];
        _titleFontName = [title objectForKey:ITERABLE_IN_APP_TEXT_FONT];
        _titleColor = [IterableInAppManager getIntFromKey:title keyString:ITERABLE_IN_APP_TEXT_COLOR];
        _titleString = [title objectForKey:ITERABLE_IN_APP_TEXT];
    }
    
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_BODY]) {
        NSDictionary* body = [jsonPayload objectForKey:ITERABLE_IN_APP_BODY];
        _bodyTextFontName = [body objectForKey:ITERABLE_IN_APP_TEXT_FONT];
        _bodyTextColor = [IterableInAppManager getIntFromKey:body keyString:ITERABLE_IN_APP_TEXT_COLOR];
        _bodyTextString = [body objectForKey:ITERABLE_IN_APP_TEXT];
    }
    
    if ([jsonPayload objectForKey:ITERABLE_IN_APP_BUTTON]) {
        NSArray* buttons = [jsonPayload objectForKey:ITERABLE_IN_APP_BUTTON];
        if ([buttons count] > 0) {
            NSDictionary* button = [buttons objectAtIndex:0];
            _buttonTextFontName = [button objectForKey:ITERABLE_IN_APP_TEXT_FONT];
            _buttonTextColor = [IterableInAppManager getIntFromKey:button keyString:ITERABLE_IN_APP_TEXT_COLOR];
            _buttonTextString = [button objectForKey:ITERABLE_IN_APP_TEXT];
            _buttonBackgroundColor = [IterableInAppManager getIntFromKey:button keyString:ITERABLE_IN_APP_BACKGROUND_COLOR];
            _buttonAction = [button objectForKey:ITERABLE_IN_APP_BUTTON_ACTION];
        }
    }
    
    _imageURL = [jsonPayload objectForKey:ITERABLE_IN_APP_IMAGE];
    
    _backgroundColor = [IterableInAppManager getIntFromKey:jsonPayload keyString:ITERABLE_IN_APP_BACKGROUND_COLOR];
}

- (void)loadView {
    [super loadView];
    
    UIColor *backgroundColor = UIColorFromRGB(_backgroundColor);
    [self.view setBackgroundColor:backgroundColor];
    
    NSInteger fontConstant = (self.view.frame.size.width > self.view.frame.size.height) ? self.view.frame.size.width : self.view.frame.size.height;
    
    self.Title = [[UILabel alloc] initWithFrame:CGRectZero];
    self.Title.textAlignment =  NSTextAlignmentCenter;
    self.Title.textColor = UIColorFromRGB(_titleColor);
    
    
    self.Title.font = [UIFont fontWithName: self.titleFontName size:(fontConstant/16)];
    self.Title.text = self.titleString;
    self.Title.numberOfLines = 2;
    
    _ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if(_imageURL != nil) {
        //Async load of the center image
        [self processImageDataWithURLString:self.imageURL andBlock:^(NSData *imageData) {
            if (self.view.window) {
                UIImage *image = [UIImage imageWithData:imageData];
                imageWidth = image.size.width;
                imageHeight = image.size.height;
                _ImageView.image = image;
                
                [self layoutCenterImage];
            }
        }];
    }
    
    self.ActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.ActionButton addTarget:self
                      action:@selector(actionButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.ActionButton setTitle:self.buttonTextString forState:UIControlStateNormal];
    [self.ActionButton setTitleColor:UIColorFromRGB(_buttonTextColor) forState:UIControlStateNormal];
    self.ActionButton.frame = CGRectMake(0, self.view.frame.size.height*.9f, self.view.frame.size.width, self.view.frame.size.height*.1f);
    self.ActionButton.backgroundColor = UIColorFromRGB(_buttonBackgroundColor);
    //Change to match the # of buttons
    self.ActionButton.tag = 0;
    NSString *actionStringValue = (_buttonAction != nil) ? self.buttonAction : @"";
    [self addActionButton:self.ActionButton.tag actionString:actionStringValue];
   
    self.TextBody = [[UILabel alloc] initWithFrame:CGRectZero];
    self.TextBody.textAlignment =  NSTextAlignmentCenter;
    self.TextBody.textColor = UIColorFromRGB(_bodyTextColor);
    self.TextBody.font = [UIFont fontWithName:self.bodyTextFontName size:(fontConstant/30)];
    self.TextBody.text = self.self.bodyTextString;
    self.TextBody.numberOfLines = 3;
    
    [self.view addSubview:_ImageView];
    [self.view addSubview:self.Title];
    [self.view addSubview:self.ActionButton];
    [self.view addSubview:self.TextBody];
}

-(UIImage*)getImage:(NSString *)imgUrl {
    NSURL *imageURL = [NSURL URLWithString:imgUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    imageWidth = image.size.width;
    imageHeight = image.size.height;

    return image;
}

- (void)processImageDataWithURLString:(NSString *)urlString andBlock:(void (^)(NSData *imageData))processImage
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_queue_t loadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(loadQueue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            processImage(imageData);
        });
    });
}

- (void)viewWillLayoutSubviews {
    CGPoint img = [self layoutCenterImage];
    
    //Float title halfway between image and top
    CGFloat titleSizeY = _ImageView.center.y - img.y/2;
    self.Title.frame = CGRectMake(0, 0, self.view.frame.size.width, titleSizeY);
    
    //Action Button
    self.ActionButton.frame = CGRectMake(0, self.view.frame.size.height*.9f, self.view.frame.size.width, self.view.frame.size.height*.1f);
    
    //Main Text
    CGFloat textBodyStartingLocation = _ImageView.center.y + img.y/2;
    self.TextBody.frame = CGRectMake(0, textBodyStartingLocation, self.view.frame.size.width*.8f, self.view.frame.size.height*.9f - textBodyStartingLocation);
    [self.TextBody setCenter:CGPointMake(self.view.center.x, textBodyStartingLocation+self.TextBody.frame.size.height/2)];
}

-(CGPoint)layoutCenterImage{
    float maxHeight;
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        maxHeight = self.view.frame.size.height*.5;
        self.TextBody.numberOfLines = 2;
        
    } else {
        maxHeight = self.view.frame.size.width * 3/4; //4:3 aspect ratio
        self.TextBody.numberOfLines = 4;
    }
    
    float newHeight = maxHeight;
    float newWidth = self.view.frame.size.width;
    
    //Center Image
    if (_ImageView.image != NULL) {
        float maxWidth = self.view.frame.size.width;
        float scaleFactor = maxWidth / imageWidth;
        if (imageHeight*scaleFactor > maxHeight) {
            scaleFactor = maxHeight / imageHeight;
        }
        newHeight = imageHeight * scaleFactor;
        newWidth = imageWidth * scaleFactor;
    }
    _ImageView.frame = CGRectMake(0, 0, newWidth, newHeight);
    [_ImageView setCenter:CGPointMake(self.view.center.x, self.view.center.y*.9f)];
    return CGPointMake(newWidth, newHeight);
}


@end

