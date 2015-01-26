//
//  RootController.m
//  tonyplaces
//
//  Created by Senja iMac on 6/8/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "RootController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaceModel.h"


@implementation RootController

@synthesize dialogNotif, dialogNotifBackground;

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
    [locationViewController release];
    [loginController release];
    [thankYouController release];
    [containerState release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)changeState:(int)state
{
    NSLog(@"changeState %d", state);
    UIView * newView;
    switch (state) {
        case stateLogin:
            newView = loginController.view;
            break;
        case stateLocation:
            newView = locationViewController.view;
            break;
        case stateThankYou:
            newView = thankYouController.view;
            break;
        case stateStillReviewing:
            newView = stillReviewingController.view;
            break;
        default:
            break;
    }
    if (currentView == newView) return;
    else {
        if (currentView != nil){
            [currentView removeFromSuperview];
        }
        [containerState addSubview:newView];
        currentView = newView;
    }
}


- (void)showNotifDialog:(NSString*)text autoHide:(BOOL)autoHide
{
    dialogNotif.text = text;
    [UIView beginAnimations:@"showNotifDialog" context:NULL];
    [UIView setAnimationDuration:0.25];
    if (autoHide){
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(showNotifDialogStop:finished:context:)];
    }
    dialogNotif.layer.opacity = 1;
    dialogNotifBackground.layer.opacity = 1;
    [UIView commitAnimations];
}

- (void)showNotifDialogStop:(NSString*) animationID finished:(NSNumber*) finished context:(void*) context 
{
    if ([animationID isEqualToString:@"showNotifDialog"]){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelay:0.75];
        dialogNotif.layer.opacity = 0;
        dialogNotifBackground.layer.opacity = 0;
        [UIView commitAnimations];
    }
}

- (void)hideNotifDialog
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    dialogNotif.layer.opacity = 0;
    dialogNotifBackground.layer.opacity = 0;
    [UIView commitAnimations];
}

#pragma mark - AppModelDelegate

- (void)appModelSearchTagsChanged
{
    [locationViewController loadVenues];
}

#pragma mark - PlacesManagerDelegate

- (void)placesManagerCheckDeviceAccess:(NSNumber *)role
{
    int r = [role intValue];
    [AppModel instance].role = r;
    if (r == ROLE_ADMIN){
        [AppModel instance].autoLogin = true;
        if ([[PlacesManager instance] isLoggedInFoursquare]){
            [[PlacesManager instance] checkAccess];
        } else {
            [self hideNotifDialog];
            [AppModel instance].autoLogin = false;
            [self changeState:stateLogin];
        }
    } else if (r == ROLE_PUBLIC){
        [self hideNotifDialog];
        [self changeState:stateLocation];
    }
}

- (void)placesManagerLoginFoursquare:(NSNumber *)status
{
    int s = [status intValue];
    if (s == LOGIN_OK){
        [[PlacesManager instance] checkAccess];
    } else if (s == LOGIN_WRONG){
        [self hideNotifDialog];
        [self showNotifDialog: [[AppModel instance].config valueForKey:@"Login Wrong Text"] autoHide:YES];
    }
    loginController.buttonGo.enabled = YES;
}

- (void)placesManagerCheckAccess:(NSNumber *)status
{
    [self hideNotifDialog];
    int s = [status intValue];
    if (s == REQUEST_PENDING){
        if ([AppModel instance].autoLogin){
            [self changeState:stateStillReviewing];
        } else {
            [self changeState:stateThankYou];
        }
    } else if (s == REQUEST_REJECTED){
        [self changeState:stateLogin];
    } else if (s == REQUEST_ACCEPTED){
        [self changeState:stateLocation];
    } else if (s == LOGIN_EXPIRED){
        [AppModel instance].autoLogin = false;
        [self changeState:stateLogin];
    }
}

- (void)placesManagerLoadNavigate:(NSArray *)places
{
    [locationViewController setNavigateData:places];
}

- (void)placesManagerLoadVenues:(NSArray *)places
{
    [locationViewController setVenuesData:places];
}

- (void)placesManagerAddVenue:(PlaceModel*)addedVenue
{
    if (addedVenue != nil){
        CLLocation * location = [[CLLocation alloc] initWithLatitude:addedVenue.latitude longitude:addedVenue.longitude];
        addedVenue.distance = [[AppModel instance].ownLocation distanceFromLocation:location];
        [location release];
        [locationViewController addNavigateData:addedVenue];
        [self showNotifDialog:[[AppModel instance].config valueForKey:@"Add Venue Finish Text"] autoHide:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //app initialization
    [AppModel instance];
    [AppModel instance].delegate = self;
    [PlacesManager instance];
    [PlacesManager instance].delegate = self;
    
    dialogNotif.layer.opacity = 0;
    dialogNotifBackground.layer.opacity = 0;
    containerState = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:containerState belowSubview:dialogNotifBackground];
    
    locationViewController = [[tonyplacesViewController alloc] init];
    loginController = [[LoginController alloc] init];
    thankYouController = [[ThankYouController alloc] init];
    stillReviewingController = [[StillReviewingController alloc] init];
    
    [self showNotifDialog:[[AppModel instance].config valueForKey:@"Logging In Text"] autoHide:NO];
    [[PlacesManager instance] checkDeviceAccess];
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

@end
