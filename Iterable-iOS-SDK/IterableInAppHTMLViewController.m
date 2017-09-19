//
//  IterableInAppHTMLViewController.m
//
//  Created by David Truong on 8/4/17.
//  Copyright © 2017 Iterable. All rights reserved.
//

#import "IterableInAppHTMLViewController.h"
#import "IterableNotificationMetadata.h"
#import "IterableAPI.h"
#import "IterableConstants.h"

@interface IterableInAppHTMLViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) UIViewController *rootViewController;
@property IterableNotificationMetadata *trackParams;
@property ITEActionBlock customBlockCallback;
@property UIEdgeInsets insetPadding;
@property NSString* htmlString;

@property (nonatomic) UIView *fullView;

@end

@implementation IterableInAppHTMLViewController

INAPP_NOTIFICATION_TYPE location;
BOOL loaded;

- (instancetype)initWithData:(NSString*)htmlString {
    self = [super init];
    self.htmlString = htmlString;
    
    return self;
}

// documented in IterableInAppHTMLViewController.h
-(void)ITESetPadding:(UIEdgeInsets)insetPadding {
    _insetPadding = insetPadding;
}

// documented in IterableInAppHTMLViewController.h
-(void)ITESetCallback:(ITEActionBlock)callbackBlock {
    _customBlockCallback = callbackBlock;
}

// documented in IterableInAppHTMLViewController.h
-(void)ITESetTrackParams:(IterableNotificationMetadata *)params {
    _trackParams = params;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     //Todo: trackDialogView
    [_webView layoutSubviews];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)loadView {
    [super loadView];
    
    if (_insetPadding.top == 0 && _insetPadding.bottom == 0) {
        location = INAPP_FULL;
    } else if (_insetPadding.top == 0 && _insetPadding.bottom < 0) {
        location = INAPP_TOP;
    } else if (_insetPadding.top < 0 && _insetPadding.bottom == 0) {
        location = INAPP_BOTTOM;
    } else if (_insetPadding.top < 0 && _insetPadding.bottom < 0) {
        location = INAPP_MIDDLE;
    }

    
    self.view.backgroundColor = [UIColor clearColor];

    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat screenHeight = CGRectGetHeight(self.view.bounds);
    
    _fullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    
    //load manually
    [_webView loadHTMLString:_htmlString baseURL:nil];
    _webView.scrollView.bounces = NO;
    //_webView.layer.masksToBounds = YES;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.bounces = NO;
    _webView.delegate=self;
    
    [_fullView addSubview:_webView];
    [self.view addSubview:_fullView];
}

- (void)viewWillLayoutSubviews {
    //handles the case of rotations and coming back from a link.
    [self resizeWebView:_webView];
}

- (void)resizeWebView:(UIWebView *)aWebView {
    if (!loaded) {
        return;
    }
    
    if (location == INAPP_FULL) {
        _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {

        float notificationWidth = 100-(_insetPadding.left + _insetPadding.right);
        
        CGRect frame = aWebView.frame;
        //Needed to fit the html to size.
        frame.size.height = 1;
        aWebView.frame = frame;
        
        CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
        frame.size = fittingSize;
        frame.size.width = CGRectGetWidth(self.view.bounds)*notificationWidth/100;
        frame.size.height = MIN(frame.size.height, CGRectGetHeight(self.view.bounds));
        aWebView.frame = frame;
        
        //Position webview
        CGPoint center = self.view.center;
        float webViewHeight = aWebView.frame.size.height/2;
        switch (location) {
            case INAPP_TOP:
                center.y = webViewHeight;
                break;
            case INAPP_BOTTOM:
                center.y = self.view.frame.size.height - webViewHeight;
                break;
        }
        aWebView.center = center;
    }
}

//UIWebViewDelegate Functions
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    loaded = true;
    [self resizeWebView:_webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *absoluteURL = [[request URL] absoluteString];
        if ([absoluteURL hasPrefix:@"itbl://"]) {
            NSLog(@"%@", absoluteURL);
            [self dismissViewControllerAnimated:NO completion:^{
                //Track analytics here for button click and close
                if (_trackParams != nil) {
                    IterableAPI *api = IterableAPI.sharedInstance;
                    [api trackInAppClick:_trackParams.messageId buttonURL:absoluteURL];
                }
            }];
            return NO;
        } else {
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:[request URL] options:@{} completionHandler:nil];
        }
        return NO;
    }
    return YES;
}

@end
