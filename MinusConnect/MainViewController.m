//
//  MainViewController.m
//  EVNConnect
//
//  Created by Kentaro ISHITOYA on 12/02/02.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import "MainViewController.h"
#import "APIKey.h"

@implementation MainViewController
- (id)init{
    self = [super init];
    if(self){
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [loginButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height / 2 - 70, 80, 30)];
        [loginButton addTarget:self action:@selector(handleLoginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [logoutButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height / 2 - 35, 80, 30)];
        [logoutButton addTarget:self action:@selector(handleLogoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
        
        UIButton *testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [testButton setTitle:@"Test" forState:UIControlStateNormal];
        [testButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height / 2 + 5, 80, 30)];
        [testButton addTarget:self action:@selector(handleTestButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:testButton];
        
        minus_ = [[MinusConnect alloc] 
                  initWithClientId:MINUS_CLIENT_ID
                  clientSecret:MINUS_CLIENT_SECRET 
                  callbackScheme:@"minusConnectTest://" 
                  andDelegate:self];
    }
    return self;
}

- (void) handleLoginButtonTapped:(UIButton *)sender{
    [minus_ loginWithUsername:MINUS_USERNAME password:MINUS_PASSWORD andPermission:[NSArray arrayWithObjects:@"read_all", @"upload_new", nil]];
}

- (void) handleTestButtonTapped:(UIButton *)sender{
    [minus_ activeUserWithDelegate:self];
    //[minus_ userWithUserId:@"kent013" andDelegate:self];
    
    [minus_ folderWithFolderId:@"bfTQDBcmP" andDelegate:self];
    //[minus_ foldersWithUsername:@"kent013" andDelegate:self];
    //[minus_ createFolderWithUsername:@"kent013" name:@"test" isPublic:NO andDelegate:self];

    //[minus_ filesWithFolderId:@"bfTQDBcmP" andDelegate:self];
    //[minus_ fileWithFileId:@"C4KkzgTMA2a9" andDelegate:self];
    /*UIImage *image = [UIImage imageNamed:@"sample1.jpg"];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [minus_ createFileWithFolderId:@"bfTQDBcmP" caption:@"test image" filename:@"sample1-1.jpg" data:data dataContentType:@"image/jpeg" andDelegate:self];*/
}

- (void) handleLogoutButtonTapped:(UIButton *)sender{
    [minus_ logout];
}

#pragma mark - MinusRequestDelegate
-(void)requestLoading:(MinusRequest *)request{
    NSLog(@"start request");
}

- (void)request:(MinusRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"did received response");
}

- (void)request:(MinusRequest *)client didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    NSLog(@"progress:%f", (float)totalBytesWritten / (float)totalBytesExpectedToWrite);
}

- (void)request:(MinusRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"request failed with error:%@", error.description);
}

- (void)request:(MinusRequest *)request didLoad:(id)result{
    if([request.tag isEqualToString:kMinusRequestActiveUser]){
        NSLog(@"active! %@", result);
    }else{
        NSLog(@"did request loaded %@", result);
    }
}

- (void)request:(MinusRequest *)request didLoadRawResponse:(NSData *)data{
    NSLog(@"did request loaded(raw)");    
}

#pragma mark - MinusSessionDelegate
/*!
 * did login to minus
 */
-(void)minusDidLogin{
}

/*!
 * did logout from minus
 */
- (void)minusDidLogout{
}

/*!
 * attempt to login, but not logined
 */
- (void)minusDidNotLogin{
}

- (UIViewController *)requestForViewControllerToPresentAuthenticationView{
    return self.navigationController;
}

#pragma mark - View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
