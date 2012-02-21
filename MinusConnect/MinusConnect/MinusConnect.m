//
//  MinusConnect.m
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MinusConnect.h"

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusConnect(PrivateImplementation)
- (void)setupInitialState;
@end

@implementation MinusConnect(PrivateImplementation)
/*!
 * initialize
 */
- (void)setupInitialState{
    requests_ = [[NSMutableSet alloc] init];
}
@end
//-----------------------------------------------------------------------------
//Public Implementations
//-----------------------------------------------------------------------------
#pragma mark - public implementation
@implementation MinusConnect
@synthesize sessionDelegate = sessionDelegate_;
/*!
 * initialize
 */
- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret 
        callbackScheme:(NSString *)callbackScheme 
           andDelegate:(id<MinusSessionDelegate>)delegate{
    self = [super init];
    if(self){
        auth_ = [[MinusAuth alloc] initWithClientId:clientId
                                       clientSecret:clientSecret 
                                     callbackScheme:callbackScheme
                                        andDelegate:self];
        self.sessionDelegate = delegate;
        [auth_ loadCredential];
        [self setupInitialState];
    }
    return self;
}

/*!
 * login
 */
- (void)login{
    if([auth_ isSessionValid] == NO){
        [auth_ login];
    }
    [self minusDidLogin];
}

/*!
 * logout
 */
- (void)logout{
    if([auth_ isSessionValid]){
        [auth_ logout];
    }
    [self minusDidLogout];
}

/*!
 * did logined
 */
- (void)minusDidLogin{
    [auth_ saveCredential];
    [self.sessionDelegate minusDidLogin];
}

/*!
 * did logout
 */
- (void)minusDidLogout{
    [auth_ clearCredential];
    [self.sessionDelegate minusDidLogout];
}

/*!
 * did not login
 */
- (void)minusDidNotLogin{
    [auth_ clearCredential];
    [self.sessionDelegate minusDidNotLogin];
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    return [auth_ isSessionValid];
}
@end
