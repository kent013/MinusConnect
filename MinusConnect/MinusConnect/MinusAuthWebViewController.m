//
//  MinusAuthWebViewController.m
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import "MinusAuthWebViewController.h"


//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusAuthWebViewController(PrivateImplementation)
- (void)setupInitialState;
@end


@implementation MinusAuthWebViewController(PrivateImplementation)
- (void)setupInitialState{
}
@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
@implementation MinusAuthWebViewController
@synthesize backButton = backButton__;
@synthesize forwardButton = forwardButton_;
@synthesize navButtonsView = navButtonsView_;
@synthesize rightBarButtonItem = rightBarButtonItem_;
@synthesize webView = webView_;
@synthesize browserCookiesURL = browserCookiesURL_;

- (id)init
{
    self = [super initWithNibName:@"MinusAuthWebView" bundle:nil];
    if (self) {
        [self setupInitialState];
    }
    return self;
}

- (void)viewDidLoad{
    rightBarButtonItem_.customView = navButtonsView_;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem_;
}


- (void)popView {
    if (self.navigationController.topViewController == self) {
        if (!self.view.isHidden) {
            [self.navigationController popViewControllerAnimated:YES];
            self.view.hidden = YES;
        }
    }
}

- (void)moveWebViewFromUnderNavigationBar {
    CGRect dontCare;
    CGRect webFrame = self.view.bounds;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    CGRectDivide(webFrame, &dontCare, &webFrame,
                 navigationBar.frame.size.height, CGRectMinYEdge);
    [self.webView setFrame:webFrame];
}

// isTranslucent is defined in iPhoneOS 3.0 on.
- (BOOL)isNavigationBarTranslucent {
    UINavigationBar *navigationBar = [[self navigationController] navigationBar];
    BOOL isTranslucent =
    ([navigationBar respondsToSelector:@selector(isTranslucent)] &&
     [navigationBar isTranslucent]);
    return isTranslucent;
}

- (void)viewWillAppear:(BOOL)animated {
    if (!isViewShown_) {
        isViewShown_ = YES;
        if ([self isNavigationBarTranslucent]) {
            [self moveWebViewFromUnderNavigationBar];
        }
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    didViewAppear_ = YES;
    [super viewDidAppear:animated];
}



- (void)clearBrowserCookies {
    NSURL *cookiesURL = [self browserCookiesURL];
    if (cookiesURL) {
        NSHTTPCookieStorage *cookieStorage;
        
        cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies =  [cookieStorage cookiesForURL:cookiesURL];
        
        for (NSHTTPCookie *cookie in cookies) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearBrowserCookies];
    
    [super viewWillDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)updateUI {
    [backButton_ setEnabled:[[self webView] canGoBack]];
    [forwardButton_ setEnabled:[[self webView] canGoForward]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateUI];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {    
    [self updateUI];
}
@end
