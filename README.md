Minus API wrapper: MinusConnect
==================================

This library is a wrapper of Minus API.  
* I did not implemented all of minus API, only what I needed.
check out [Minus.h](https://github.com/kent013/MinusConnect/blob/master/MinusConnect/MinusConnect/MinusConnect.h) for supported API. 

Usage
---------------------------------
### 1, Copy source files in [MinusConnect](https://github.com/kent013/MinusConnect/tree/master/MinusConnect/MinusConnect) and [Util](https://github.com/kent013/MinusConnect/tree/master/MinusConnect/Util) into your project.


### 2, Put 3rd party libraries into your project and configure them.
Libraries are stored in [Libraries](https://github.com/kent013/MinusConnect/tree/master/Libraries)

### 3, Code.  

[MainViewController.h](https://github.com/kent013/MinusConnect/blob/master/MinusConnect/MainViewController.h)

    #import "MinusConnect.h"
    @interface MainViewController : UIViewController<MinusSessionDelegate, MinusRequestDelegate>{
        __strong MinusConnect *minus_;
    }
    @property (nonatomic, readonly) MinusConnect *minus; 
    @end

[MainViewController.m](https://github.com/kent013/MinusConnect/blob/master/MinusConnect/MainViewController.m)

#### 3.1, initialize minus wrapper
Initialize `MinusConnect` class as below. Where `MINUS_CLIENT_ID` and `MINUS_CLIENT_SECRET` are provided by minus. And `callbackScheme` is url scheme which you configured in your project(I think it is not needed for now). 

    //create instance of MinusConnect
    minus_ = [[MinusConnect alloc] 
              initWithClientId:MINUS_CLIENT_ID
              clientSecret:MINUS_CLIENT_SECRET 
              callbackScheme:nil 
              andDelegate:self];

#### 3.2, login to minus
Now you can call `[minus_ loginWithUsername:password:andPermission:]` method to login to Minus with oAuth2.0. 

    [minus_ loginWithUsername:MINUS_USERNAME password:MINUS_PASSWORD andPermission:[NSArray arrayWithObjects:@"read_all", @"upload_new", nil]];

#### 3.3, MinusSessionDelegate

    #pragma mark - MinusSessionDelegate
    -(void)minusDidLogin{
    }
    - (void)minusDidLogout{
    }
    - (void)minusDidNotLogin{
    }

#### 3.4, send request 
Now you can request to Minus API. You may implement MinusRequestDelegate to handle response from server. 
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


License
-------------------------------------
Copyright (c) 2012, ISHITOYA Kentaro. 

New BSD License. See [LICENSE](https://github.com/kent013/MinusConnect/blob/master/LICENSE) file. 

3rd Party Library Licenses
------------------------------------
will be filled out later.