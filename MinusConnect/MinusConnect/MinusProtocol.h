//
//  MinusProtocol.h
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * endpoint urls
 */
static NSString *kMinusBaseURL = @"https://minus.com/api/v2/";
static NSString *kMinusOAuthRequestURL = @"https://minus.com/api/v2/";
static NSString *kMinusOAuthAuthenticationURL = @"https://minus.com/oauth/token";

/*!
 * credential keys
 */
static NSString *kMinusAccessToken = @"minusAuthToken";

@class MinusRequest;

/*!
 * delegate for session
 */
@protocol MinusSessionDelegate <NSObject>
- (void)minusDidLogin;
- (void)minusDidNotLogin;
- (void)minusDidLogout;
@end

/*!
 * delegate for minus request
 */
@protocol MinusRequestDelegate <NSObject>
@optional
- (void)requestLoading:(MinusRequest*)request;
- (void)request:(MinusRequest*)request didReceiveResponse:(NSURLResponse*)response;
- (void)request:(MinusRequest*)request didFailWithError:(NSError*)error;
- (void)request:(MinusRequest*)request didFailWithException:(NSException*)exception;
- (void)request:(MinusRequest*)request didLoad:(id)result;
- (void)request:(MinusRequest*)request didLoadRawResponse:(NSData*)data;
- (void)request:(MinusRequest*)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end
