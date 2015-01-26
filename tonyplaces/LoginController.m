//
//  LoginController.m
//  tonyplaces
//
//  Created by Senja iMac on 6/7/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "LoginController.h"
#import "PlacesManager.h"
#import "AppContext.h"
#import "AppModel.h"


@implementation LoginController

@synthesize tableLogin, cellEmail, cellPassword, textEmail, textPassword, buttonGo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)keyboardOpened
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = -165;
    self.view.frame = newFrame;
    [UIView commitAnimations];
}

- (void)closeKeyboard
{
    if (activeTextField != nil){
        [activeTextField resignFirstResponder];
        activeTextField = nil;
    }
    
    if (self.view.frame.origin.y < 0){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = 0;
        self.view.frame = newFrame;
        [UIView commitAnimations];
    }
}

- (void)buttonGoTouch:(id)sender
{
    buttonGo.enabled = NO;
    [self closeKeyboard];
    [[AppContext mainController] showNotifDialog:[[AppModel instance].config valueForKey:@"Logging In Text"] autoHide:NO];
    [[PlacesManager instance] loginFoursquare:textEmail.text password:textPassword.text];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tableLogin.rowHeight = 44;
    tableLogin.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    tableLogin.separatorColor = [UIColor colorWithWhite:112.f/256.f alpha:1];
    tableLogin.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableLogin.tableHeaderView = tableLogin.tableFooterView = nil;
    
    [buttonGo addTarget:self action:@selector(buttonGoTouch:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == tableLogin){
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tableLogin){
        if (indexPath.row == 0){
            return cellEmail;
        } else if (indexPath.row == 1){
            return cellPassword;
        }
    } 
    return nil;
}

#pragma mark - TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    [self keyboardOpened];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self closeKeyboard];
    return YES;
}


@end
