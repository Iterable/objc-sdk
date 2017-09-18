//
//  IterableInAppHTMLViewController.m
//
//  Created by David Truong on 8/4/17.
//  Copyright © 2017 Iterable. All rights reserved.
//

#import "IterableInAppHTMLViewController.h"
#import "IterableNotificationMetadata.h"
#import "IterableAPI.h"

@interface IterableInAppHTMLViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) UIViewController *rootViewController;
@property IterableNotificationMetadata *trackParams;

@property (nonatomic) UIView *fullView;

@end

@implementation IterableInAppHTMLViewController

-(void)ITESetTrackParams:(IterableNotificationMetadata *)params {
    _trackParams = params;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     //trackDialogView
    [_webView layoutSubviews];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];

    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat screenHeight = CGRectGetHeight(self.view.bounds);
    
    _fullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    
    
    NSString *textOutStations = [NSString stringWithFormat:@"<style>.nav {display: inline-block;background-color: #00B2EE;border: 1px solid #000000;border-width: 1px 0px;margin: 0;padding: 0;min-width: 1000px;width: 100%;}.nav li {list-style-type: none;width: 14.28%;float: left;}.nav a {display: inline-block;padding: 10px 0;width: 100%;text-align: center;} body {background-color: transparent;}h4 {color: maroon;margin-left: 40px;}</style><header><span class=\"banner_h\"><img src=\"Images\Top_Banner_4.png\" alt=\"Banner\" height=\"150\" width =\"140\" /></span><nav><ul class=\"nav\"><li><a href=\"itbl://index\">Home</a></li><li><a href=\"about.html\">About Us</a></li></ul></nav></header> Hello Everyone. Please check out the new website:<br> <a href=\"itbl://close\">clicky</a> here. <a href=\"www.google.com\">googled?</a>  <a href=\"app_link://testlinks\">  testLinks?</a><a href=\"otherstringname\">otherstring?</a>"];
    
        textOutStations = @"<HEAD><style>body {background-color: linen;}h4 {color: maroon;margin-left: 40px;} .portrait {width: 300;max-height: 100%;}</style><TITLE>Basic HTML Sample Page</TITLE></HEAD><BODY BGCOLOR=\"WHITE\"><CENTER><H1>A Simple Sample Web Page</H1><div class=\"portrait\"><img src=\"https://pbs.twimg.com/profile_images/808895199447486464/yjnIVncG.jpg\"></div><H4>By Sheldon Brown</H4><H2>Demonstrating a few HTML features</H2></CENTER>HTML is really a very simple language. It consists of ordinary text, with commands that are enclosed by \"<\" and \">\" characters. <P>You don't really need to know much HTML to create a page, because you can copy bits of HTML from other pages that do what you want, then change the text!<P>This page shows on the left as it appears in your browser, and the corresponding HTML code appears on the right. The HTML commands are linked to explanations of what they do.<H3>Line Breaks</H3>HTML doesn't normally use line breaks for ordinary text. A white space of any size is treated as a single space. This is because the author of the page has no way of knowing the size of the reader's screen, or what size type they will have their browser set for.<P>If you want to put a line break at a particular place, you can use the BR command, or, for a paragraph break, the P command, which will insert a blank line. The heading command (pr) puts a blank line above and below the heading text.<H4>Starting and Stopping Commands</H4>Most HTML commands come in pairs: for example, H4 marks the beginning of a size 4 heading, and H4 marks the end of it. The closing command is always the same as the opening command, except for the addition of the \"/\".<P>Modifiers are sometimes included along with the basic command, inside the opening command's < >. The modifier does not need to be repeated in the closing command.<H1>This is a size 1 heading</H1><H2>This is a size 2 heading</H2><H3>This is a size 3 heading</H3><H4>This is a size 4 heading</H4><H5>This is a size 5 heading</H5><H6>This is a size 6 heading</H6><center><H4>Copyright © 1997, by<A HREF=\"www.sheldonbrown.com/index.html\">Sheldon Brown</A></H4>If you would like to make a link or bookmark to this page, the URL is:<BR> www.sheldonbrown.com/web_sample1.html</body>";

    
    textOutStations = @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional //EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\"><head><!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><meta name=\"viewport\" content=\"width=device-width\"/><!--[if !mso]><!--><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"/><!--<![endif]--><title>Simple</title><style type=\"text/css\" id=\"media-query\"> body { margin: 0; padding: 0; } table, tr, td { vertical-align: top; border-collapse: collapse; } .ie-browser table, .mso-container table { table-layout: fixed; } * { line-height: inherit; } a[x-apple-data-detectors=true] { color: inherit !important; text-decoration: none !important; } [owa] .img-container div, [owa] .img-container button { display: block !important; } [owa] .fullwidth button { width: 100% !important; } [owa] .block-grid .col { display: table-cell; float: none !important; vertical-align: top; } .ie-browser .num12, .ie-browser .block-grid, [owa] .num12, [owa] .block-grid { width: 480px !important; } .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; } .ie-browser .mixed-two-up .num4, [owa] .mixed-two-up .num4 { width: 160px !important; } .ie-browser .mixed-two-up .num8, [owa] .mixed-two-up .num8 { width: 320px !important; } .ie-browser .block-grid.two-up .col, [owa] .block-grid.two-up .col { width: 240px !important; } .ie-browser .block-grid.three-up .col, [owa] .block-grid.three-up .col { width: 160px !important; } .ie-browser .block-grid.four-up .col, [owa] .block-grid.four-up .col { width: 120px !important; } .ie-browser .block-grid.five-up .col, [owa] .block-grid.five-up .col { width: 96px !important; } .ie-browser .block-grid.six-up .col, [owa] .block-grid.six-up .col { width: 80px !important; } .ie-browser .block-grid.seven-up .col, [owa] .block-grid.seven-up .col { width: 68px !important; } .ie-browser .block-grid.eight-up .col, [owa] .block-grid.eight-up .col { width: 60px !important; } .ie-browser .block-grid.nine-up .col, [owa] .block-grid.nine-up .col { width: 53px !important; } .ie-browser .block-grid.ten-up .col, [owa] .block-grid.ten-up .col { width: 48px !important; } .ie-browser .block-grid.eleven-up .col, [owa] .block-grid.eleven-up .col { width: 43px !important; } .ie-browser .block-grid.twelve-up .col, [owa] .block-grid.twelve-up .col { width: 40px !important; } @media only screen and (min-width: 500px) { .block-grid { width: 480px !important; } .block-grid .col { display: table-cell; Float: none !important; vertical-align: top; } .block-grid .col.num12 { width: 480px !important; } .block-grid.mixed-two-up .col.num4 { width: 160px !important; } .block-grid.mixed-two-up .col.num8 { width: 320px !important; } .block-grid.two-up .col { width: 240px !important; } .block-grid.three-up .col { width: 160px !important; } .block-grid.four-up .col { width: 120px !important; } .block-grid.five-up .col { width: 96px !important; } .block-grid.six-up .col { width: 80px !important; } .block-grid.seven-up .col { width: 68px !important; } .block-grid.eight-up .col { width: 60px !important; } .block-grid.nine-up .col { width: 53px !important; } .block-grid.ten-up .col { width: 48px !important; } .block-grid.eleven-up .col { width: 43px !important; } .block-grid.twelve-up .col { width: 40px !important; } } @media (max-width: 500px) { .block-grid, .col { min-width: 320px !important; max-width: 100% !important; } .block-grid { width: calc(100% - 40px) !important; } .col { width: 100% !important; } .col > div { margin: 0 auto; } img.fullwidth { max-width: 100% !important; } } </style></head><body class=\"clean-body\" style=\"margin: 0;padding: 0;-webkit-text-size-adjust: 100%;background-color: transparent\"><!--[if IE]><div class=\"ie-browser\"><![endif]--><!--[if mso]><div class=\"mso-container\"><![endif]--><div class=\"nl-container\" style=\"overflow:hidden;border-radius:25px;min-width: 320px;Margin: 0 auto;background-color: transparent\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" style=\"background-color: #FFFFFF;\"><![endif]--><div style=\"background-color:#323341;\"><div style=\"Margin: 0 auto;min-width: 320px;max-width: 480px;width: 480px;width: calc(17000% - 84520px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\" class=\"block-grid \"><div style=\"border-collapse: collapse;display: table;width: 100%;\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"background-color:#323341;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 480px;\"><tr class=\"layout-full-width\" style=\"background-color:transparent;\"><![endif]--><!--[if (mso)|(IE)]><td align=\"center\" width=\"480\" style=\" width:480px; padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><![endif]--><div class=\"col num12\" style=\"min-width: 320px;max-width: 480px;width: 480px;width: calc(16000% - 76320px);background-color: transparent;\"><div style=\"background-color: transparent; width: 100% !important;\"><!--[if (!mso)&(!IE)]><!--><div style=\"border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\"><!--<![endif]--><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top: 5px; padding-bottom: 20px;\"><![endif]--><div style=\"color:#ffffff;line-height:120%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; padding-right: 0px; padding-left: 0px; padding-top: 5px; padding-bottom: 20px;\"><div style=\"font-size:13px;line-height:16px;color:#ffffff;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;text-align:left;\"><p style=\"margin: 0;font-size: 14px;line-height: 17px;text-align: center\"><strong><span style=\"font-size: 28px; line-height: 33px;\">NEW RELEASE:</span></strong></p><p style=\"margin: 0;font-size: 14px;line-height: 17px;text-align: center\"><strong><span style=\"font-size: 28px; line-height: 33px;\">HTML In-App Notifications</span></strong></p></div></div><!--[if mso]></td></tr></table><![endif]--><div align=\"center\" class=\"img-container center\" style=\"padding-right: 0px; padding-left: 0px;\"><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px;\" align=\"center\"><![endif]--><a href=\"https://iterable.com\" target=\"_blank\"><img class=\"center\" align=\"center\" border=\"0\" src=\"https://app.iterable.com/assets/templates/builder/img/bee_rocket.png\" alt=\"Image\" title=\"Image\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;width: 100%;max-width: 402px\" width=\"402\"/></a><!--[if mso]></td></tr></table><![endif]--></div><!--[if (!mso)&(!IE)]><!--></div><!--<![endif]--></div></div><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div></div><div style=\"background-color:#61626F;\"><div style=\"Margin: 0 auto;min-width: 320px;max-width: 480px;width: 480px;width: calc(17000% - 84520px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\" class=\"block-grid \"><div style=\"border-collapse: collapse;display: table;width: 100%;\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"background-color:#61626F;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 480px;\"><tr class=\"layout-full-width\" style=\"background-color:transparent;\"><![endif]--><!--[if (mso)|(IE)]><td align=\"center\" width=\"480\" style=\" width:480px; padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><![endif]--><div class=\"col num12\" style=\"min-width: 320px;max-width: 480px;width: 480px;width: calc(16000% - 76320px);background-color: transparent;\"><div style=\"background-color: transparent; width: 100% !important;\"><!--[if (!mso)&(!IE)]><!--><div style=\"border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent; padding-top:0px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\"><!--<![endif]--><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 5px;\"><![endif]--><div style=\"color:#ffffff;line-height:120%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 5px;\"><div style=\"font-size:13px;line-height:16px;color:#ffffff;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;text-align:left;\"><p style=\"margin: 0;font-size: 18px;line-height: 22px;text-align: center\"><span style=\"font-size: 24px; line-height: 28px;\"><strong>Fully customizable HTML In-App Notifications</strong></span></p></div></div><!--[if mso]></td></tr></table><![endif]--><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 0px; padding-bottom: 0px;\"><![endif]--><div style=\"color:#B8B8C0;line-height:150%;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; padding-right: 10px; padding-left: 10px; padding-top: 0px; padding-bottom: 0px;\"><div style=\"font-size:13px;line-height:20px;color:#B8B8C0;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;text-align:left;\"><p style=\"margin: 0;font-size: 14px;line-height: 21px;text-align: center\"><span style=\"font-size: 14px; line-height: 21px;\">Design and launch your own mobile in-app notifications with our built in HTML editor.</span></p></div></div><!--[if mso]></td></tr></table><![endif]--><div align=\"center\" class=\"button-container center\" style=\"padding-right: 10px; padding-left: 10px; padding-top:15px; padding-bottom:10px;\"><!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"border-spacing: 0; border-collapse: collapse; mso-table-lspace:0pt; mso-table-rspace:0pt;\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top:15px; padding-bottom:10px;\" align=\"center\"><v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" href=\"itbl://close\" style=\"height:36px; v-text-anchor:middle; width:187px;\" arcsize=\"70%\" strokecolor=\"#C7702E\" fillcolor=\"#C7702E\"><w:anchorlock/><center style=\"color:#ffffff; font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size:16px;\"><![endif]--><a href=\"itbl://close\" target=\"_blank\" style=\"display: inline-block;text-decoration: none;-webkit-text-size-adjust: none;text-align: center;color: #ffffff; background-color: #C7702E; border-radius: 25px; -webkit-border-radius: 25px; -moz-border-radius: 25px; max-width: 167px; width: 127px; width: 35%; border-top: 0px solid transparent; border-right: 0px solid transparent; border-bottom: 0px solid transparent; border-left: 0px solid transparent; padding-top: 0px; padding-right: 20px; padding-bottom: 5px; padding-left: 20px; font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif;mso-border-alt: none\"><span style=\"font-size:16px;line-height:32px;\"><span style=\"font-size: 14px; line-height: 28px;\" data-mce-style=\"font-size: 14px;\">Launch Now</span></span></a><!--[if mso]></center></v:roundrect></td></tr></table><![endif]--></div><div style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px;\"><!--[if (mso)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px;padding-left: 10px; padding-top: 10px; padding-bottom: 10px;\"><table width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td><![endif]--><div align=\"center\"><div style=\"border-top: 0px solid transparent; width:100%; line-height:0px; height:0px; font-size:0px;\">&#160;</div></div><!--[if (mso)]></td></tr></table></td></tr></table><![endif]--></div><!--[if (!mso)&(!IE)]><!--></div><!--<![endif]--></div></div><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div></div><div style=\"background-color:#ffffff;\"><div style=\"Margin: 0 auto;min-width: 320px;max-width: 480px;width: 480px;width: calc(17000% - 84520px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;\" class=\"block-grid \"><div style=\"border-collapse: collapse;display: table;width: 100%;\"><!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"background-color:#ffffff;\" align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width: 480px;\"><tr class=\"layout-full-width\" style=\"background-color:transparent;\"><![endif]--><!--[if (mso)|(IE)]><td align=\"center\" width=\"480\" style=\" width:480px; padding-right: 0px; padding-left: 0px; padding-top:30px; padding-bottom:30px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><![endif]--><div class=\"col num12\" style=\"min-width: 320px;max-width: 480px;width: 480px;width: calc(16000% - 76320px);background-color: transparent;\"><div style=\"background-color: transparent; width: 100% !important;\"><!--[if (!mso)&(!IE)]><!--><div style=\"border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent; padding-top:30px; padding-bottom:30px; padding-right: 0px; padding-left: 0px;\"><!--<![endif]--><div align=\"center\" style=\"padding-right: 10px; padding-left: 10px; padding-bottom: 10px;\"><div style=\"line-height:10px;font-size:1px\">&#160;</div><div style=\"display: table; max-width:151;\"><!--[if (mso)|(IE)]><table width=\"131\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"border-collapse:collapse; padding-right: 10px; padding-left: 10px; padding-bottom: 10px;\" align=\"center\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"border-collapse:collapse; mso-table-lspace: 0pt;mso-table-rspace: 0pt; width:131px;\"><tr><td width=\"32\" style=\"width:32px; padding-right: 5px;\" valign=\"top\"><![endif]--><table align=\"left\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"32\" height=\"32\" style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 5px\"><tbody><tr style=\"vertical-align: top\"><td align=\"left\" valign=\"middle\" style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\"><a href=\"https://www.facebook.com/\" title=\"Facebook\" target=\"_blank\"><img src=\"https://d2fi4ri5dhpqd1.cloudfront.net/public/resources/social-networks-icon-sets/circle-color/facebook.png\" alt=\"Facebook\" title=\"Facebook\" width=\"32\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;max-width: 32px !important\"/></a></td></tr></tbody></table><!--[if (mso)|(IE)]></td><td width=\"32\" style=\"width:32px; padding-right: 5px;\" valign=\"top\"><![endif]--><table align=\"left\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"32\" height=\"32\" style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 5px\"><tbody><tr style=\"vertical-align: top\"><td align=\"left\" valign=\"middle\" style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\"><a href=\"http://twitter.com/\" title=\"Twitter\" target=\"_blank\"><img src=\"https://d2fi4ri5dhpqd1.cloudfront.net/public/resources/social-networks-icon-sets/circle-color/twitter.png\" alt=\"Twitter\" title=\"Twitter\" width=\"32\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;max-width: 32px !important\"/></a></td></tr></tbody></table><!--[if (mso)|(IE)]></td><td width=\"32\" style=\"width:32px; padding-right: 0;\" valign=\"top\"><![endif]--><table align=\"left\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"32\" height=\"32\" style=\"border-collapse: collapse;table-layout: fixed;border-spacing: 0;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 0\"><tbody><tr style=\"vertical-align: top\"><td align=\"left\" valign=\"middle\" style=\"word-break: break-word;border-collapse: collapse !important;vertical-align: top\"><a href=\"http://plus.google.com/\" title=\"Google+\" target=\"_blank\"><img src=\"https://d2fi4ri5dhpqd1.cloudfront.net/public/resources/social-networks-icon-sets/circle-color/googleplus.png\" alt=\"Google+\" title=\"Google+\" width=\"32\" style=\"outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block !important;border: none;height: auto;float: none;max-width: 32px !important\"/></a></td></tr></tbody></table><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div><!--[if (!mso)&(!IE)]><!--></div><!--<![endif]--></div></div><!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]--></div></div></div><!--[if (mso)|(IE)]></td></tr></table><![endif]--></div><!--[if (mso)|(IE)]></div><![endif]--></body></html>";
    
    
    //load manually
    [_webView loadHTMLString:textOutStations baseURL:nil];
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
    CGRect frame = aWebView.frame;
    //Needed to fit the html to size.
    frame.size.height = 1;
    aWebView.frame = frame;
    
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    frame.size.width = CGRectGetWidth(self.view.bounds)*.8f;
    frame.size.height = MIN(frame.size.height, CGRectGetHeight(self.view.bounds));
    aWebView.frame = frame;
    
    //resize in center of screen
    [self recenterWebView:aWebView];
}

- (void)recenterWebView:(UIWebView *)aWebView {
    //position in center of screen
    aWebView.center = self.view.center;
}


//UIWebViewDelegate Functions
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [self resizeWebView:_webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
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
        }
        else {
            UIApplication *application = [UIApplication sharedApplication];
            [application openURL:[request URL] options:@{} completionHandler:nil];
            
        }
        return NO;
    }
    return YES;
}

@end
