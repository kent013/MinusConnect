//
//  MinusConnect.m
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/21.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MinusConnect.h"

static NSString* kUserAgent = @"MinusConnect";
static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
static NSString* kHTTPGET = @"GET";
static NSString* kHTTPPOST = @"POST";
static NSString* kHTTPPUT = @"PUT";
static NSString* kHTTPDELETE = @"DELETE";
static const NSTimeInterval kTimeoutInterval = 180.0;

//-----------------------------------------------------------------------------
//Private Implementations
//-----------------------------------------------------------------------------
@interface MinusConnect(PrivateImplementation)
- (void)setupInitialState;
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data;
- (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod;
- (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params;
- (NSMutableData *)generatePostBody:(NSDictionary *)params;
- (MinusRequest *) createRequestWithURLString:(NSString *)url 
                                        param:(NSDictionary *)params 
                                httpMethod:(NSString *)httpMethod
                                 andDelegate:(id<MinusRequestDelegate>)delegate;
@end

@implementation MinusConnect(PrivateImplementation)
/*!
 * initialize
 */
- (void)setupInitialState{
    requests_ = [[NSMutableSet alloc] init];
}

/*!
  * Body append for POST method
  */
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
    [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 * Generate get URL
 */
- (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params {
    return [self serializeURL:baseUrl params:params httpMethod:kHTTPGET];
}

/**
 * Generate get URL
 */
- (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod {
    baseUrl = [NSString stringWithFormat:@"%@/%@", kMinusBaseURL, baseUrl];
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            if ([httpMethod isEqualToString:@"GET"]) {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value = 
        (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                            (__bridge CFStringRef)[params objectForKey:key],
                                                            NULL,
                                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                            kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@&bearer_token=%@", baseUrl, queryPrefix, query, auth_.credential.accessToken];
}

/*!
 * Generate body for POST method
 */
- (NSMutableData *)generatePostBody:(NSDictionary *)params {
    NSMutableData *body = [NSMutableData data];
    NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    [self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]];
    
    for (id key in [params keyEnumerator]) {
        
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            
            [dataDictionary setObject:[params valueForKey:key] forKey:key];
            continue;
            
        }
        
        [self utfAppendBody:body
                       data:[NSString
                             stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                             key]];
        [self utfAppendBody:body data:[params valueForKey:key]];
        
        [self utfAppendBody:body data:endLine];
    }
    
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            NSObject *dataParam = [dataDictionary valueForKey:key];
            if ([dataParam isKindOfClass:[UIImage class]]) {
                NSData* imageData = UIImageJPEGRepresentation((UIImage*)dataParam, 1.0);
                [self utfAppendBody:body
                               data:[NSString stringWithFormat:
                                     @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
                [self utfAppendBody:body
                               data:[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"]];
                [body appendData:imageData];
            } else {
                NSAssert([dataParam isKindOfClass:[NSData class]],
                         @"dataParam must be a UIImage or NSData");
                [self utfAppendBody:body
                               data:[NSString stringWithFormat:
                                     @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
                [self utfAppendBody:body
                               data:[NSString stringWithString:@"Content-Type: content/unknown\r\n\r\n"]];
                [body appendData:(NSData*)dataParam];
            }
            [self utfAppendBody:body data:endLine];
            
        }
    }
    
    return body;
}

/*!
 * create request
 */
- (MinusRequest *) createRequestWithURLString:(NSString *)url param:(NSDictionary *)params httpMethod:(NSString *)httpMethod andDelegate:(id<MinusRequestDelegate>)delegate{
    NSString *serializedUrl = [self serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serializedUrl]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:kTimeoutInterval];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    
    [request setHTTPMethod:httpMethod];
    if ([httpMethod isEqualToString: @"POST"]) {
        NSString* contentType = [NSString
                                 stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[self generatePostBody:params]];
    }
    return [[MinusRequest alloc] initWithURLRequest:request andDelegate:delegate];
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

#pragma mark - authentication
/*!
 * login
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password andPermission:(NSArray *)permission{
    if([auth_ isSessionValid] == NO){
        [auth_ loginWithUsername:username password:password andPermission:permission];
    }else{
        [self minusDidLogin];
    }
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
 * request for navigation controller
 */
- (UIViewController *)requestForViewControllerToPresentAuthenticationView{
    return [self.sessionDelegate requestForViewControllerToPresentAuthenticationView];
}

/*!
 * is session valid
 */
- (BOOL)isSessionValid{
    return [auth_ isSessionValid];
}

#pragma mark - api
/*!
 * get active user.
 */
- (MinusRequest *)activeUserWithDelegate:(id<MinusRequestDelegate>) delegate{
    MinusRequest *request = [self createRequestWithURLString:@"activeuser" param:nil httpMethod:@"GET" andDelegate:delegate];
    [request start];
    return request;
}

/*!
 * get folders
 */
- (MinusRequest *)foldersWithDelegate:(id<MinusRequestDelegate>) delegate{
    return nil;
}

/*!
 * create file
 */
- (MinusRequest *)createFileWithDelegate:(id<MinusRequestDelegate>) delegate{
    return nil;    
}

/*!
 * create folder
 */
- (MinusRequest *)createFolderWithDelegate:(id<MinusRequestDelegate>) delegate{
    return nil;
}
@end
