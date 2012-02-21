//
//  MinusAuth.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MinusAuth.h"
#import "PDKeychainBindings.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusAuth(PrivateImplementation)
@end

@implementation MinusAuth(PrivateImplementation)

@end

//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - authentication
@implementation MinusAuth
/*!
 * initialize
 */
- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret
        callbackScheme:(NSString *)callbackScheme
           andDelegate:(id<MinusAuthDelegate>)delegate{
    self = [super init];
    if (self) {
        clientId_ = clientId;
        clientSecret_ = clientSecret;
        callbackScheme_ = callbackScheme;
        delegate_ = delegate;
        authViewController_ = [[MinusAuthWebViewController alloc] init];
    }
    return self;
}

/*!
 * login to minus, obtain request token
 */
-(void)login {
    if([self isSessionValid]){
        [self minusDidLogin];
        return;
    }
    
    client_ = [[LROAuth2Client alloc] 
               initWithClientID: clientId_
               secret: clientSecret_
               redirectURL:[NSURL URLWithString:callbackScheme_]];
    client_.delegate = self;
    client_.userURL  = [NSURL URLWithString:kMinusOAuthRequestURL];
    client_.tokenURL = [NSURL URLWithString:kMinusOAuthAuthenticationURL];
    [client_ authorizeUsingWebView:authViewController_.webView];
}

/*!
 * logout
 */
- (void)logout {
    [self clearCredential];
    if ([delegate_ respondsToSelector:@selector(minusDidLogout)]) {
        [delegate_ minusDidLogout];
    }
}

/*!
 * send did login message
 */
- (void)minusDidLogin{
    if ([delegate_ respondsToSelector:@selector(minusDidLogin)]) {
        [delegate_ minusDidLogin];
    }
    
}

/*!
 * send did not login message
 */
- (void)minusDidNotLogin{
    if ([delegate_ respondsToSelector:@selector(minusDidNotLogin:)]) {
        [delegate_ minusDidNotLogin];
    }
}

#pragma mark - credentials
/*!
 * clear access token
 */
- (void)clearCredential{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    [bindings removeObjectForKey:kMinusAccessToken];
}

/*!
 * load credential
 */
- (void)loadCredential{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    NSData *data = [[bindings objectForKey:kMinusAccessToken] dataUsingEncoding:NSASCIIStringEncoding];
    accessToken_ = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

/*!
 * save credential
 */
- (void)saveCredential{
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    [bindings setObject:[[NSString alloc] initWithData:[NSKeyedArchiver archivedDataWithRootObject:accessToken_] encoding:NSASCIIStringEncoding] forKey:kMinusAccessToken];
}

/*!
 * refresh credential
 */
- (void)refreshCredential{
    if([self isSessionValid] == NO){
        [client_ refreshAccessToken:accessToken_];
    }
}

/*!
 * check is session valid
 */
- (BOOL)isSessionValid{
    return [accessToken_ hasExpired];
}

#pragma mark - LROAuth2ClientDelegate
/*!
 * server responds request token
 */
- (void)oauthClientDidReceiveAccessToken:(LROAuth2Client *)client{
    accessToken_ = client.accessToken;
}

/*!
 * server responds to refresh token
 */
- (void)oauthClientDidRefreshAccessToken:(LROAuth2Client *)client{
    accessToken_ = client.accessToken;    
}
@end
