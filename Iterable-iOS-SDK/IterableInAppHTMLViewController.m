//
//  IterableInAppHTMLViewController.m
//
//  Created by David Truong on 8/4/17.
//  Copyright © 2017 Iterable. All rights reserved.
//

#import "IterableInAppHTMLViewController.h"
#import "IterableNotificationMetadata.h"
#import "IterableLogging.h"
#import "IterableAPI.h"
#import "IterableConstants.h"

@interface IterableInAppHTMLViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property IterableNotificationMetadata *trackParams;
@property ITEActionBlock customBlockCallback;
@property UIEdgeInsets insetPadding;
@property NSString* htmlString;

@end

@implementation IterableInAppHTMLViewController

static NSString *const customUrlScheme = @"applewebdata";
static NSString *const httpUrlScheme = @"http://";
static NSString *const httpsUrlScheme = @"https://";
static NSString *const itblUrlScheme = @"itbl://";

INAPP_NOTIFICATION_TYPE location;
BOOL loaded;

- (instancetype)initWithData:(NSString*)htmlString {
    self = [super init];
    self.htmlString = htmlString;
    return self;
}

// documented in IterableInAppHTMLViewController.h
-(NSString*)getHtml {
    return self.htmlString;
}

// documented in IterableInAppHTMLViewController.h
-(void)ITESetPadding:(UIEdgeInsets)insetPadding {
    _insetPadding = insetPadding;
    
    if ((_insetPadding.left + _insetPadding.right) >= 100) {
        LogWarning(@"Can't display an in-app with padding > 100%. Defaulting to 0 for padding left/right");
        
        _insetPadding.left = 0;
        _insetPadding.right = 0;
    }
}

// documented in IterableInAppHTMLViewController.h
-(void)ITESetCallback:(ITEActionBlock)callbackBlock {
    _customBlockCallback = callbackBlock;
}

// documented in IterableInAppHTMLViewController.h
-(void)ITESetTrackParams:(IterableNotificationMetadata *)params {
    _trackParams = params;
}

/**
 @method
 
 @abstract Tracks an inApp open and layouts the webview
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_trackParams != nil) {
        IterableAPI *api = IterableAPI.sharedInstance;
        [api trackInAppOpen:_trackParams.messageId];
    }
    [_webView layoutSubviews];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

/**
 @method
 
 @abstract Loads the view and sets up the webView
 */
- (void)loadView {
    [super loadView];
    
    location = [IterableInAppHTMLViewController setLocation:_insetPadding];

    self.view.backgroundColor = [UIColor clearColor];

    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat screenHeight = CGRectGetHeight(self.view.bounds);

    _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [_webView loadHTMLString:_htmlString baseURL:[NSURL URLWithString:@""]];
    _webView.scrollView.bounces = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.bounces = NO;
    _webView.delegate=self;
    
    [self.view addSubview:_webView];
}


/**
 @method
 
 @abstract Handles rotations and navigation coming back from an external link.
 */
- (void)viewWillLayoutSubviews {
    [self resizeWebView:_webView];
}

/**
 @method
 
 @abstract Resizes the webview based upon the insetPadding if the html is finished loading
 
 @param aWebView the webview
 */
- (void)resizeWebView:(UIWebView *)aWebView {
    if (loaded) {
        if (location == INAPP_FULL) {
            _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } else {
            //Resizes the frame to match the HTML content with a max of the screen size.
            CGRect frame = aWebView.frame;
            frame.size.height = 1;
            aWebView.frame = frame;
            CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
            frame.size = fittingSize;
            double notificationWidth = 100-(_insetPadding.left + _insetPadding.right);
            double screenWidth = CGRectGetWidth(self.view.bounds);
            frame.size.width = screenWidth*notificationWidth/100;
            frame.size.height = MIN(frame.size.height, CGRectGetHeight(self.view.bounds));
            aWebView.frame = frame;
            
            float resizeCenterX = screenWidth*(_insetPadding.left + notificationWidth/2)/100;
            
            //Position webview
            CGPoint center = self.view.center;;
            float webViewHeight = aWebView.frame.size.height/2;
            switch (location) {
                case INAPP_TOP:
                    center.y = webViewHeight;
                    break;
                case INAPP_BOTTOM:
                    center.y = self.view.frame.size.height - webViewHeight;
                    break;
                case INAPP_CENTER:
                    break;
                case INAPP_FULL:
                    break;
            }
            center.x = resizeCenterX;
            aWebView.center = center;
        }
    }
}

// documented in IterableInAppHTMLViewController.h
+ (INAPP_NOTIFICATION_TYPE)setLocation:(UIEdgeInsets) insetPadding {
    INAPP_NOTIFICATION_TYPE locationType;
    if (insetPadding.top == 0 && insetPadding.bottom == 0) {
        locationType = INAPP_FULL;
    } else if (insetPadding.top == 0 && insetPadding.bottom < 0) {
        locationType = INAPP_TOP;
    } else if (insetPadding.top < 0 && insetPadding.bottom == 0) {
        locationType = INAPP_BOTTOM;
    } else {
        locationType = INAPP_CENTER;
    }
    
    return locationType;
}

//////////////////////////////////////////////////////////////
/// @name UIWebViewDelegate Functions
//////////////////////////////////////////////////////////////

/**
 @method
 
 @abstract Resizes the webview after it is finished loading
 
 @param aWebView the webview
 */
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    loaded = true;
    [self resizeWebView:_webView];
}

/**
 @method
 
 @abstract  Handles when a link is clicked within the webView.
 
 @param     webView the webview
 @param     request the NSURLRequest
 @param     navigationType the navigation type
 
 @return    If the webView handles the click
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *destinationURL = [[request URL] absoluteString];
        NSString *callbackURL = [[request URL] absoluteString];
        
        if ([request.URL.scheme isEqualToString:customUrlScheme]) {
            // Since we are calling loadHTMLString with a nil baseUrl, any request url without a valid scheme get treated as a local resource.
            //Removes the extra applewebdata scheme/host data that is appended to the original url.
            NSArray *urlArray = [destinationURL componentsSeparatedByString: request.URL.host];
            NSString *urlPath = urlArray[1];
            destinationURL = urlPath;
            if (urlPath.length > 0) {
                //Removes extra "/" from the url path
                unichar firstChar = [urlPath characterAtIndex:0];
                if (firstChar == '/') {
                    destinationURL = [urlPath substringFromIndex:1];
                }
            }
            callbackURL = destinationURL;
            
            //Warn the client that the request url does not contain a valid scheme
            LogWarning(@"Request url contains an invalid scheme: %a", destinationURL);
        } else if ([destinationURL hasPrefix:itblUrlScheme]) {
            NSString * strNoURLScheme = [destinationURL stringByReplacingOccurrencesOfString:itblUrlScheme withString:@""];
            callbackURL = strNoURLScheme;
        }
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.customBlockCallback != nil) {
                self.customBlockCallback(callbackURL);
            }
            
            if (self.trackParams != nil) {
                IterableAPI *api = IterableAPI.sharedInstance;
                [api trackInAppClick:self.trackParams.messageId buttonURL:destinationURL];
            }
        }];
        return NO;
    }
    return YES;
}

@end
