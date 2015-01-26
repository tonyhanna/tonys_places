//
//  LoginController.h
//  tonyplaces
//
//  Created by Senja iMac on 6/7/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
    UITableView * tableLogin;
    UITableViewCell * cellEmail;
    UITableViewCell * cellPassword;
    UITextField * textEmail;
    UITextField * textPassword;
    UIButton * buttonGo;
    
    UITextField * activeTextField;
}

@property (nonatomic,retain) IBOutlet UITableView * tableLogin;
@property (nonatomic,retain) IBOutlet UITableViewCell * cellEmail;
@property (nonatomic,retain) IBOutlet UITableViewCell * cellPassword;
@property (nonatomic,retain) IBOutlet UITextField * textEmail;
@property (nonatomic,retain) IBOutlet UITextField * textPassword;
@property (nonatomic,retain) IBOutlet UIButton * buttonGo;


@end
