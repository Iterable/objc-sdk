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

static NSString *const smsUrlScheme = @"sms";
static NSString *const emailUrlScheme = @"sms";


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
    
    if ((_insetPadding.left + _insetPadding.right) >= 100) {
        LogWarning(@"Can't display an in-app with padding > 100. Defaulting to 0 for padding left/right");
        
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

    _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [_webView loadHTMLString:_htmlString baseURL:[NSURL URLWithString:nil]];
    _webView.scrollView.bounces = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scrollView.bounces = NO;
    _webView.delegate=self;
    
    [self.view addSubview:_webView];
}

- (void)viewWillLayoutSubviews {
    //handles rotations and navigation coming back from an external link.
    [self resizeWebView:_webView];
}

- (void)resizeWebView:(UIWebView *)aWebView {
    if (!loaded) {
        return;
    }
    
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
        
        double resizeCenterX = screenWidth*(_insetPadding.left + notificationWidth/2)/100;
        
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
        float ex = center.x;
        center.x = resizeCenterX;
        aWebView.center = center;
    }
}

//////////////////////////////////////////////////////////////
/// @name UIWebViewDelegate Functions
//////////////////////////////////////////////////////////////

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    loaded = true;
    [self resizeWebView:_webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *destinationURL = [[request URL] absoluteString];
        NSString *callbackURL = [[request URL] absoluteString];
        
        // Since we are calling loadHTMLString with a nil baseUrl, any request url without a valid scheme get treated as a local resource.
        // Those local resources get re-written with the applewebdata scheme.
        // Any urls with valid schemes (XXX://, http, https, apple supported schemes) remain untouched
        if ([request.URL.scheme isEqualToString:customUrlScheme]) {
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
        } else {
            NSString *urlScheme = request.URL.scheme;
            if ([urlScheme isEqualToString:httpUrlScheme] || [urlScheme isEqualToString:httpsUrlScheme]) {
                UIApplication *application = [UIApplication sharedApplication];
                [application openURL:[request URL] options:@{} completionHandler:nil];
            }
        }
        [self dismissViewControllerAnimated:NO completion:^{
            if (_customBlockCallback != nil) {
                _customBlockCallback(callbackURL);
            }
            
            if (_trackParams != nil) {
                IterableAPI *api = IterableAPI.sharedInstance;
                [api trackInAppClick:_trackParams.messageId buttonURL:destinationURL];
            }
        }];
        return NO;
    }
    return YES;
}

@end
