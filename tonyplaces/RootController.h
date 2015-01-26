//
//  RootController.h
//  tonyplaces
//
//  Created by Senja iMac on 6/8/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tonyplacesViewController.h"
#import "LoginController.h"
#import "ThankYouController.h"
#import "StillReviewingController.h"
#import "AppModel.h"

@interface RootController : UIViewController<PlacesManagerDelegate,AppModelDelegate> {
    UIView * containerState;
    UILabel * dialogNotif;
    UIImageView * dialogNotifBackground;
    
    tonyplacesViewController * locationViewController;
    LoginController * loginController;
    ThankYouController * thankYouController;
    StillReviewingController * stillReviewingController;
    
    UIView * currentView;
}

@property (nonatomic,retain) IBOutlet UILabel * dialogNotif;
@property (nonatomic,retain) IBOutlet UIImageView * dialogNotifBackground;

- (void)changeState:(int)state;
- (void)showNotifDialog:(NSString*)text autoHide:(BOOL)autoHide;
- (void)hideNotifDialog;

@end
