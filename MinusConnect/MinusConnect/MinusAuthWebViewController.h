//
//  MinusAuthWebViewController.h
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 cocotomo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MinusAuthWebViewController : UIViewController<UIWebViewDelegate>{
    __strong UIButton *backButton_;
    __strong UIButton *forwardButton_;
    __strong UIView *navButtonsView_;
    __strong UIBarButtonItem *rightBarButtonItem_;
    __strong UIWebView *webView_;
    
    NSURL *browserCookiesURL_;
    
    BOOL isInsideShouldAutorotateToInterfaceOrientation_;
    BOOL isViewShown_;
    BOOL didViewAppear_;
    BOOL hasNotifiedWebViewStartedLoading_;
    BOOL didDismissSelf_;
}
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *forwardButton;
@property (nonatomic, retain) IBOutlet UIView *navButtonsView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSURL *browserCookiesURL;
@end
