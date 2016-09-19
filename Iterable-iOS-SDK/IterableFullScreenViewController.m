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
/*@property (nonatomic, strong) UILabel* Title;
@property (nonatomic, strong) UILabel* TextBody;
@property (nonatomic, strong) UIButton* ActionButton;*/

//todo use these
@property (nonatomic) NSDictionary *actionButtons;

@end

@implementation IterableFullScreenViewController

CGFloat imageWidth =0;
CGFloat imageHeight =0;

NSDictionary *inAppPayload;

-(void)setData:(NSDictionary *)jsonPayload {
    _inAppPayload = jsonPayload;
    
    _titleFontName = jsonPayload[ITERABLE_IN_APP_TITLE][ITERABLE_IN_APP_TEXT_FONT];
    _titleColor = jsonPayload[ITERABLE_IN_APP_TITLE][ITERABLE_IN_APP_TEXT_COLOR];
    _titleString = jsonPayload[ITERABLE_IN_APP_TITLE][ITERABLE_IN_APP_TEXT];
    
    _bodyTextFontName = jsonPayload[ITERABLE_IN_APP_BODY][ITERABLE_IN_APP_TEXT_FONT];
    _bodyTextColor = jsonPayload[ITERABLE_IN_APP_BODY][ITERABLE_IN_APP_TEXT_COLOR];
    _bodyTextString = jsonPayload[ITERABLE_IN_APP_BODY][ITERABLE_IN_APP_TEXT];
    
    _buttonTextFontName = jsonPayload[ITERABLE_IN_APP_BUTTON][ITERABLE_IN_APP_TEXT_FONT];
    _buttonTextColor = jsonPayload[ITERABLE_IN_APP_BUTTON][ITERABLE_IN_APP_TEXT_COLOR];
    _buttonTextString = jsonPayload[ITERABLE_IN_APP_BUTTON][ITERABLE_IN_APP_TEXT];
    _buttonBackgroundColor = jsonPayload[ITERABLE_IN_APP_BUTTON][ITERABLE_IN_APP_BACKGROUND_COLOR];
}

- (void)loadView {
    [super loadView];
    
    //GetUIColor from _
    {
        float customR;
        float customG;
        float customB;
        float customAlpha = 0.0;
        
        UIColor *customColor = [UIColor colorWithRed: 22.0f/255.0f
                                             green: 58.0f/255.0f
                                              blue: 95.0f/255.0f
                                             alpha: customAlpha];
        
    }
    
    // Do any additional setup after loading the view.
    UIColor *backgroundColor = [UIColor colorWithRed: 22.0f/255.0f
                                               green: 58.0f/255.0f
                                                blue: 95.0f/255.0f
                                               alpha: 1.0f];
    [self.view setBackgroundColor:backgroundColor];
    
    NSInteger fontConstant = (self.view.frame.size.width > self.view.frame.size.height) ? self.view.frame.size.width : self.view.frame.size.height;
    
    self.Title = [[UILabel alloc] initWithFrame:CGRectZero];
    self.Title.textAlignment =  NSTextAlignmentCenter;
    self.Title.textColor = [UIColor whiteColor];
    
    
    //update font getter
    self.Title.font = [UIFont fontWithName: self.titleString size:(fontConstant/16)];
    self.Title.text = self.titleString;
    self.Title.numberOfLines = 2;
    
    _ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //Add in lazy loading
    [self processImageDataWithURLString:self.inAppPayload[ITERABLE_IN_APP_IMAGE] andBlock:^(NSData *imageData) {
        if (self.view.window) {
            UIImage *image = [UIImage imageWithData:imageData];
            imageWidth = image.size.width;
            imageHeight = image.size.height;
            _ImageView.image = image;
            
            [self layoutCenterImage];
        }
    }];
    //_ImageView.image = [self getImage:inAppPayload[ITERABLE_IN_APP_IMAGE]];
    
    self.ActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.ActionButton addTarget:self
                      action:@selector(actionButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.ActionButton setTitle:self.buttonTextString forState:UIControlStateNormal];
    [self.ActionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.ActionButton.frame = CGRectMake(0, self.view.frame.size.height*.9f, self.view.frame.size.width, self.view.frame.size.height*.1f);
    self.ActionButton.backgroundColor = [UIColor colorWithRed: 1.0f
                                                    green: 1.0f
                                                     blue: 1.0f
                                                    alpha: 0.1f];
    //Change to match the # of buttons
    self.ActionButton.tag = 0;
    NSString *actionStringValue = @"fake action string";
    [self addActionButton:self.ActionButton.tag actionString:actionStringValue];

    self.TextBody = [[UILabel alloc] initWithFrame:CGRectZero];
    self.TextBody.textAlignment =  NSTextAlignmentNatural;
    self.TextBody.textColor = [UIColor whiteColor];
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
    
    //find alternative to this deprecated function
    dispatch_queue_t requestQueue = dispatch_get_current_queue();
    dispatch_queue_t downloadQueue = dispatch_queue_create(NULL, NULL);
    dispatch_async(downloadQueue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(requestQueue, ^{
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
    self.TextBody.frame = CGRectMake(0, textBodyStartingLocation, self.view.frame.size.width, self.view.frame.size.height*.9f - textBodyStartingLocation);
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


