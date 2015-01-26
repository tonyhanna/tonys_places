//
//  PlacesCellViewController.m
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/30/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "PlacesTableViewCell.h"
#import "MathUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "AppModel.h"
#import "PlaceModel.h"

@implementation PlacesTableViewCell

@synthesize delegate, textCaption, textSubcaption, textDistance, containerAccessory, arrow, buttonAdd, buttonRemove, place;

static CGRect containerAccessoryFrame;

- (void)initOnce
{
}

- (void)initView:(int)_tabType withDelegate:(id)_delegate
{  
    stateEditing = editingOff;
    containerAccessoryFrame = containerAccessory.frame;
    tabType = _tabType;
    delegate = _delegate;
    buttonRemove.hidden = true;
    if (tabType == tabNavigate){
        arrow.hidden = false;
        buttonAdd.hidden = true;
        textDistance.textColor = [UIColor colorWithWhite:217.f/256.f alpha:1];
    } else if (tabType == tabAddVenue){
        arrow.hidden = true;
        buttonAdd.hidden = false;
        textDistance.text = @"Add";
        [buttonAdd addTarget:self action:@selector(buttonAddTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.editingAccessoryType = UITableViewCellAccessoryNone;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected){
        [self insertSubview:self.selectedBackgroundView aboveSubview:self.backgroundView];
    } else {
        [self.selectedBackgroundView removeFromSuperview];
    }
}

- (void)refresh
{
    if (tabType == tabNavigate){
        if (stateEditing == editingOff || stateEditing == editingOffToOn){
            if (place.distance >= 100000){
                textDistance.text = [NSString stringWithFormat:@"%.0f km", place.distance/1000.f];
            }
            else if (place.distance >= 10000){
                textDistance.text = [NSString stringWithFormat:@"%.1f km", place.distance/1000.f];
            } else if (place.distance >= 1000){
                textDistance.text = [NSString stringWithFormat:@"%.2f km", place.distance/1000.f];
            } else {
                textDistance.text = [NSString stringWithFormat:@"%.0f m", place.distance];
            }
            [self rotateArrow:(place.bearing - [[AppModel instance] getAvailableHeading])];
        } 
    }
}

- (void)buttonAddTouch:(id)sender
{
    if ([delegate respondsToSelector:@selector(placesCellButtonAddTouch:)]){
        [delegate performSelector:@selector(placesCellButtonAddTouch:) withObject:self];
    }
}

- (void)rotateArrow:(double)degree 
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TABLE_UPDATE_INTERVAL];
    [arrow.layer setValue:[NSNumber numberWithDouble:toRadian(degree)] forKeyPath:@"transform.rotation.z"];
    [UIView commitAnimations];
}

+ (NSString *)reuseIdentifierType:(int)_tabType
{
    if (_tabType == tabNavigate){
        return @"PlacesTableViewCellNavigate";
    } else if (_tabType == tabAddVenue){
        return @"PlacesTableViewCellAddVenue";
    } else {
        return @"PlacesTableViewCell";
    }
}

- (NSString*)reuseIdentifier
{
    return [PlacesTableViewCell reuseIdentifierType:tabType];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //don't move containerAccessory left in editing mode
    containerAccessory.frame = containerAccessoryFrame;
}

- (void)transitionEditingHalfStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (stateEditing != editingOffToOn) return;
    stateEditing = editingOn;
    buttonRemove.hidden = NO;
    textDistance.textColor = [UIColor colorWithWhite:112.f/256.f alpha:1];
    textDistance.text = @"Remove";
    arrow.hidden = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [containerAccessory.layer setValue:[NSNumber numberWithDouble:toRadian(0)] forKeyPath:@"transform.rotation.y"];
    [UIView commitAnimations];
}

- (void)transitionNotEditingHalfStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (stateEditing != editingOnToOff) return;
    stateEditing = editingOff;
    buttonRemove.hidden = YES;
    textDistance.textColor = [UIColor colorWithWhite:217.f/256.f alpha:1];
    textDistance.text = [NSString stringWithFormat:@"%.0f m", place.distance];
    [arrow.layer setValue:[NSNumber numberWithDouble:toRadian(place.bearing - [[AppModel instance] getAvailableHeading])] forKeyPath:@"transform.rotation.z"];
    arrow.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [containerAccessory.layer setValue:[NSNumber numberWithDouble:toRadian(0)] forKeyPath:@"transform.rotation.y"];
    [UIView commitAnimations];
}

/*
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSLog(@"%@ setEditing %d %d", textCaption.text, editing, animated);
    [super setEditing:editing animated:animated];
}*/

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    //NSLog(@"%@ willTransitionToState %d", textCaption.text, state);
    [super willTransitionToState:state];
    if (tabType == tabNavigate){
        [UIView setAnimationsEnabled:YES];
        if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask){
            for (UIView *subview in self.subviews) {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {             
                    subview.hidden = YES;
                }
            }
            if (stateEditing == editingOff){
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(transitionEditingHalfStop:finished:context:)];
                [containerAccessory.layer setValue:[NSNumber numberWithDouble:toRadian(90)] forKeyPath:@"transform.rotation.y"];
                [UIView commitAnimations];
                stateEditing = editingOffToOn;
            } else {
                [containerAccessory.layer setValue:[NSNumber numberWithDouble:toRadian(0)] forKeyPath:@"transform.rotation.y"];
                stateEditing = editingOn;
                buttonRemove.hidden = NO;
                textDistance.text = @"Remove";
                arrow.hidden = YES;
            }
        } else if ((state & UITableViewCellStateDefaultMask) == UITableViewCellStateDefaultMask){
            if (stateEditing == editingOn){
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(transitionNotEditingHalfStop:finished:context:)];
                [containerAccessory.layer setValue:[NSNumber numberWithDouble:toRadian(90)] forKeyPath:@"transform.rotation.y"];
                [UIView commitAnimations];
                stateEditing = editingOnToOff;
            } else {
                [containerAccessory.layer setValue:[NSNumber numberWithDouble:toRadian(0)] forKeyPath:@"transform.rotation.y"];
                stateEditing = editingOff;
                buttonRemove.hidden = YES;
                textDistance.text = [NSString stringWithFormat:@"%.0f m", place.distance];
                [arrow.layer setValue:[NSNumber numberWithDouble:toRadian(place.bearing - [[AppModel instance] getAvailableHeading])] forKeyPath:@"transform.rotation.z"];
                arrow.hidden = NO;
            }
        }
    }
}

/*
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
}*/

@end
