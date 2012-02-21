//
//  MinusConnect.h
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinusProtocol.h"
#import "MinusAuth.h"
#import "MinusRequest.h"

@interface MinusConnect : NSObject<MinusAuthDelegate>{
    __strong NSMutableSet *requests_;
    __strong MinusAuth *auth_;
    __weak id<MinusSessionDelegate> sessionDelegate_;
}

@property(nonatomic, weak) id<MinusSessionDelegate> sessionDelegate;

#pragma - authentication

- (id)initWithClientId:(NSString *)clientId 
          clientSecret:(NSString *)clientSecret 
        callbackScheme:(NSString *)callbackScheme 
           andDelegate:(id<MinusSessionDelegate>)delegate;

- (void)login;
- (void)logout;
- (BOOL)isSessionValid;
@end
