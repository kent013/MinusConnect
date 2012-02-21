//
//  MainViewController.h
//  MinusConnect
//
//  Created by Kentaro ISHITOYA on 12/02/02.
//  Copyright (c) 2012 Kentaro ISHITOYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MinusConnect.h"

@interface MainViewController : UIViewController<MinusSessionDelegate, MinusRequestDelegate>{
    __strong MinusConnect *minus_;
}
@end
