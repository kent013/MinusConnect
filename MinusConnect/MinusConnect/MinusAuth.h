//
//  MinusAuth.h
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinusProtocol.h"
#import "LROAuth2Client.h"
#import "LROAuth2AccessToken.h"
#import "MinusAuthWebViewController.h"

@protocol MinusAuthDelegate;


/*!
 * minus auth object
 */
@interface MinusAuth : NSObject<LROAuth2ClientDelegate>{
  @protected
    __strong NSString *callbackScheme_;
    __strong NSString *clientId_;
    __strong NSString *clientSecret_;

    __strong LROAuth2Client *client_;
    __strong LROAuth2AccessToken *accessToken_;
    
    __strong MinusAuthWebViewController *authViewController_;
    id<MinusAuthDelegate> delegate_;
}

- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret 
        callbackScheme:(NSString *)callbackScheme 
           andDelegate:(id<MinusAuthDelegate>)delegate;
- (void)login;
- (void)logout;
- (void)minusDidLogin;
- (void)minusDidNotLogin;
- (void)clearCredential;
- (void)loadCredential;
- (void)saveCredential;
- (void)refreshCredential;
- (BOOL)isSessionValid;
@end

/*!
 * delegate for consumer engine
 */
@protocol MinusAuthDelegate <NSObject>
- (void)minusDidLogin;
- (void)minusDidNotLogin;
- (void)minusDidLogout;
@end