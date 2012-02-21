//
//  MinusAuth.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/03.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MinusAuth.h"
#import "NSString+Join.h"

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
@synthesize credential = accessToken_;

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
        //authViewController_ = [[MinusAuthWebViewController alloc] init];
    }
    return self;
}

/*!
 * login to minus, obtain request token
 */
-(void)loginWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission {
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
    /* We dont need web view to be presented for now
     UIViewController *viewController = [delegate_ requestForViewControllerToPresentAuthenticationView];
    if([viewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *navigationController = (UINavigationController *)viewController;
        [navigationController pushViewController:authViewController_ animated:YES];
    }else{
        [viewController presentModalViewController:authViewController_ animated:YES];
    }
    webView_ = [[UIWebView alloc] init];
    [client_ authorizeUsingWebView:webView_ additionalParameters:params];
    */
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString join:permission glue:@" "], @"scope", 
                            @"password", @"grant_type", 
                            username, @"username",
                            password, @"password",
                            clientSecret_, @"client_secret", nil];

    NSURLRequest *request = [client_ userAuthorizationRequestWithParameters:params];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    if(connection == nil){
        [self minusDidNotLogin];
        return;
    }
    [connection start];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults removeObjectForKey:kMinusAccessToken];
    [defaults synchronize];
    accessToken_ = nil;
}

/*!
 * load credential
 */
- (void)loadCredential{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSData *data = [defaults objectForKey:kMinusAccessToken];
    if(data != nil){
        accessToken_ = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

/*!
 * save credential
 */
- (void)saveCredential{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken_];
    [defaults setValue:data forKey:kMinusAccessToken];
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

#pragma mark - NSURLConnectionDelegate
#pragma mark - NSURLConnection[Data]Delegate methods
/*!
 * did receive response
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    data_ = [[NSMutableData alloc] init];
    
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode != 200) {
        [connection cancel];
        NSLog(@"%s:HTTP Response is %d", __PRETTY_FUNCTION__, statusCode);
        return;
    }
}

/*!
 * append data
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [data_ appendData:data];
}


/*!
 * did fail with error
 */
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error{
    NSLog(@"%s, %@", __PRETTY_FUNCTION__, error.description);
}

/*!
 * did finish loading
 */
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [client_ processAuthorizationResponse:data_];
}

#pragma mark - LROAuth2ClientDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self minusDidLogin];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self minusDidNotLogin];
}
/*!
 * server responds request token
 */
- (void)oauthClientDidReceiveAccessToken:(LROAuth2Client *)client{
    accessToken_ = client.accessToken;
    [self minusDidLogin];
}

/*!
 * server responds to refresh token
 */
- (void)oauthClientDidRefreshAccessToken:(LROAuth2Client *)client{
    accessToken_ = client.accessToken;    
}
@end
