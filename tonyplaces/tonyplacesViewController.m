//
//  tonyplacesViewController.m
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/27/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "tonyplacesViewController.h"
#import "LocationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "AppModel.h"
#import "PlaceModel.h"
#import "AppContext.h"
#import "LoginController.h"
#import "PlaceAnnotation.h"
#import "MathUtil.h"
#import "CenterMapViewGestureRecognizer.h"


@implementation MKAnnotationView (Sorting)
- (NSComparisonResult)compareCenterY:(MKAnnotationView*)view
{
    CGPoint selfPoint = [self.superview convertPoint:CGPointMake(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height) toView:nil];
    CGPoint viewPoint = [view.superview convertPoint:CGPointMake(view.frame.origin.x + view.frame.size.width/2, view.frame.origin.y + view.frame.size.height) toView:nil];
    //NSLog(@"%f %f", selfPoint.y, viewPoint.y);
    if (selfPoint.y < viewPoint.y) return NSOrderedDescending;
    else if (selfPoint.y > viewPoint.y) return NSOrderedAscending;
    else return NSOrderedSame;
}
@end

@implementation tonyplacesViewController

@synthesize containerTable, placesTable, tabBar;

- (void)dealloc
{
    [navigateData release];
    [venuesData release];
    [navigateAnnotations release];
    [venuesAnnotations release];
    
    [placesTable release];
    [mapView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (float)mapRangeForDistance:(float)distance
{
    return MAP_SCALE*distance+500;
}

- (void)setMapViewAnnotations:(NSArray*)annotations
{
    for (id a in mapView.annotations){
        if (a != mapView.userLocation){
            [mapView removeAnnotation:a];
        }
    }
    [mapView addAnnotations:annotations];
    
    float mapRange;
    if ([placesTable dataSource].count > 0){
        mapRange = MAX(MAP_SCALE*DEFAULT_MAP_RANGE, [self mapRangeForDistance:((PlaceModel*)[[placesTable dataSource] objectAtIndex:([placesTable dataSource].count-1)]).distance]);
    } else {
        mapRange = MAP_SCALE * DEFAULT_MAP_RANGE;
    }
    [mapView setRegion:[mapView regionThatFits:MKCoordinateRegionMakeWithDistance([AppModel instance].ownLocation.coordinate, 2*mapRange, 2*mapRange)] animated:YES];
}

- (void)setNavigateData:(NSArray*)places
{
    loadingNavigate = false;
    if (navigateData) [navigateData release];
    navigateData = [[NSMutableArray alloc] initWithCapacity:places.count];
    if (navigateIds) [navigateIds release];
    navigateIds = [[NSMutableDictionary alloc] initWithCapacity:places.count];
    [navigateAnnotations removeAllObjects];
    for (PlaceModel * place in places){
        place.addedNavigate = true;
        [navigateData addObject:place];
        [navigateIds setValue:[NSNumber numberWithBool:true] forKey:place.venueId];
        
        PlaceAnnotation * annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude);
        annotation.place = place;
        [navigateAnnotations addObject:annotation];
        [annotation release];
    }
    if (tabSelected == tabNavigate){
        [[AppContext mainController] hideNotifDialog];
        [placesTable setDataSource:navigateData tabType:tabSelected];
        [self setMapViewAnnotations:navigateAnnotations];
    }
}

- (void)addNavigateData:(PlaceModel *)place
{
    CLLocation * location = [[CLLocation alloc] initWithLatitude:place.latitude longitude:place.longitude];
    place.distance = [[AppModel instance].ownLocation distanceFromLocation:location];  
    place.addedNavigate = true;
    //sort by distance
    int i;
    for (i=0; i<navigateData.count; i++){
        if (((PlaceModel*)[navigateData objectAtIndex:i]).distance > place.distance){
            break;
        }
    }
    [navigateData insertObject:place atIndex:i];
    [navigateIds setValue:[NSNumber numberWithBool:true] forKey:place.venueId];
    PlaceAnnotation * annotation = [[PlaceAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude);
    annotation.place = place;
    [navigateAnnotations insertObject:annotation atIndex:i];
    if (tabSelected == tabNavigate){
        [placesTable setDataSource:navigateData tabType:tabSelected];
        [mapView addAnnotation:annotation];
    }
    [annotation release];
}
     
- (void)setVenuesData:(NSArray*)places
{
    loadingVenues = false;
    if (venuesData) [venuesData release];
    venuesData = [[NSMutableArray alloc] initWithCapacity:places.count];
    [venuesAnnotations removeAllObjects];
    for (PlaceModel * place in places){
        if ([navigateIds valueForKey:place.venueId] != nil){
            place.addedNavigate = true;
        }
        [venuesData addObject:place];
        PlaceAnnotation * annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude);
        annotation.place = place;
        [venuesAnnotations addObject:annotation];
        [annotation release];
    }
    if (tabSelected == tabAddVenue){
        [[AppContext mainController] hideNotifDialog];
        [placesTable setDataSource:venuesData tabType:tabSelected];
        [self setMapViewAnnotations:venuesAnnotations];
    }
}

- (void)reloadTableLimited
{
    CFTimeInterval now = CFAbsoluteTimeGetCurrent();
    if (now - lastTableSort > TABLE_RESORT_INTERVAL){
        [placesTable resortRows];
        lastTableSort = now;
    }
    else if (now - lastTableReload > TABLE_UPDATE_INTERVAL){
        [placesTable reloadVisibleCells];
        lastTableReload = now;
    }
}

- (void)loadNavigate
{
    loadingNavigate = true;
    [[PlacesManager instance] loadNavigate:[AppModel instance].ownLocation];
    if (tabSelected == tabNavigate){
        [[AppContext mainController] showNotifDialog: [[AppModel instance].config valueForKey:@"Locating You Text"] autoHide:NO];
    }
}

- (void)loadVenues
{
    loadingVenues = true;
    [[PlacesManager instance] loadVenues:[AppModel instance].ownLocation withSearchTags:[AppModel instance].searchTags];
    if (tabSelected == tabAddVenue){
        [[AppContext mainController] showNotifDialog: [[AppModel instance].config valueForKey:@"Loading Venues Text"] autoHide:NO];
    }
}

- (void)reloadNavigateAndVenues:(NSTimer*)timer
{
    //NSLog(@"reload");
    if ([lastLocationReload distanceFromLocation:[AppModel instance].ownLocation] > DATA_RELOAD_DISTANCE){
        [self loadNavigate];
        if ([AppModel instance].role == ROLE_ADMIN){
            [self loadVenues];
        }
        [lastLocationReload release];
        lastLocationReload = [[AppModel instance].ownLocation retain];
    }
}

- (void)showTabNavigate
{
    if (tabSelected == tabNavigate) return;
    tabSelected = tabNavigate;
    [[AppContext mainController] hideNotifDialog];
    [placesTable setDataSource:navigateData tabType:tabSelected];
    [self setMapViewAnnotations:navigateAnnotations];
    if (loadingNavigate){
        [[AppContext mainController] showNotifDialog: [[AppModel instance].config valueForKey:@"Locating You Text"] autoHide:NO];
    }
}

- (void)showTabAddVenue
{
    if (tabSelected == tabAddVenue) return;
    tabSelected = tabAddVenue;
    [[AppContext mainController] hideNotifDialog];
    [placesTable setDataSource:venuesData tabType:tabSelected];
    [self setMapViewAnnotations:venuesAnnotations];
    if (loadingVenues){
        [[AppContext mainController] showNotifDialog: [[AppModel instance].config valueForKey:@"Loading Venues Text"] autoHide:NO];
    }
}

- (void)buttonNavigateTouch:(id)sender
{
    [self showTabNavigate];
}

- (void)buttonAddVenueTouch:(id)sender
{
    [self showTabAddVenue];
}

- (bool)mapViewVisible
{
    return placesTable.mapView.frame.origin.y + placesTable.mapView.frame.size.height > 0;
}

- (void)tripleTapGestureHandler:(UITapGestureRecognizer *)sender
{
    if (tabSelected == tabNavigate){
        [self loadNavigate];
    }
    else if (tabSelected == tabAddVenue){
        [self loadVenues];
    }
}

- (NSMutableArray*)getAnnotationViews
{
    NSMutableArray * annotationViews = [[[NSMutableArray alloc] initWithCapacity:mapView.annotations.count] autorelease];
    for (id annotation in mapView.annotations) {
        MKAnnotationView *annotationView = [mapView viewForAnnotation:annotation]; 
        if (annotationView != nil){
            [annotationViews addObject:annotationView];
        }
    }
    return annotationViews;
}

- (void)reorderAnnotationViews:(NSMutableArray*)annotationViews
{
    float mapRotation = -toRadian([[AppModel instance] getAvailableHeading]);
    NSTimeInterval now = CFAbsoluteTimeGetCurrent();
    lastReorderAnnotation = now;
    lastReorderRotation = mapRotation;
    //reorder annotations
    [annotationViews sortUsingSelector:@selector(compareCenterY:)];
    for (int i=1; i<annotationViews.count; i++){
        MKAnnotationView *annotationView = [annotationViews objectAtIndex:i];
        //NSLog(@"%f", annotationView.center.y);
        [annotationView.superview insertSubview:annotationView belowSubview:[annotationViews objectAtIndex:i-1]];
    }
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)_tabBar didSelectItem:(UITabBarItem *)item
{
    int index = [_tabBar.items indexOfObject:item];
    if (index == 0){
        [self buttonNavigateTouch:item];
    } else if (index == 1){
        [self buttonAddVenueTouch:item];
    }
}

#pragma mark - PlacesTableViewControllerDelegate

- (void)placesTableAddButtonTouch:(PlaceModel *)place
{
    NSLog(@"add %@", place);
    [[PlacesManager instance] addVenue:place];
}

- (void)placesTableRowSelected:(NSIndexPath *)indexPath
{
    if ([self mapViewVisible]){
        NSArray * currentAnnotations;
        NSArray * places = [placesTable dataSource];
        if (tabSelected == tabNavigate){ 
            currentAnnotations = navigateAnnotations; 
        }
        else if (tabSelected == tabAddVenue){ 
            currentAnnotations = venuesAnnotations; 
        }
        PlaceAnnotation * annotation;
        annotation = [currentAnnotations objectAtIndex:indexPath.row];
        annotation.directCall = true;
        [mapView selectAnnotation:annotation animated:YES];
        
        PlaceModel * place = [places objectAtIndex:indexPath.row];
        
        float mapRange = [self mapRangeForDistance:place.distance];
        //if (region.span.longitudeDelta > mapView.region.span.longitudeDelta){
            [mapView setRegion:[mapView regionThatFits:MKCoordinateRegionMakeWithDistance([AppModel instance].ownLocation.coordinate, 2*mapRange, 2*mapRange)] animated:YES];
        //}
    }
}

- (void)placesTableRowDeselected:(NSIndexPath *)indexPath
{
    [mapView deselectAnnotation:[mapView.selectedAnnotations objectAtIndex:0] animated:NO];
}

- (void)placesTableDeleteRow:(NSIndexPath *)indexPath
{
    if (tabSelected == tabNavigate){
        [[PlacesManager instance] removeVenue:[navigateData objectAtIndex:indexPath.row]];
        PlaceModel * place = [navigateData objectAtIndex:indexPath.row];
        [navigateIds removeObjectForKey:place.venueId];
        NSArray * venuesRemoved = [venuesData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"venueId == %@", place.venueId]];
        for (PlaceModel * v in venuesRemoved){
            v.addedNavigate = false;
        }
        
        [navigateData removeObjectAtIndex:indexPath.row];
        [mapView removeAnnotation:[navigateAnnotations objectAtIndex:indexPath.row]];
        [navigateAnnotations removeObjectAtIndex:indexPath.row];
    }
}
         
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == _mapView.userLocation){
        return nil;
    } else {
        float mapRotation = -toRadian([[AppModel instance] getAvailableHeading]);
        MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"placeAnnotationView"];
        annView.pinColor = MKPinAnnotationColorRed;
        annView.animatesDrop = NO;
        [annView setTransform:CGAffineTransformMakeRotation(-mapRotation)];
        return annView;
    }
}

- (void)mapView:(MKMapView *)_mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (view.annotation != _mapView.userLocation){
        MKPinAnnotationView * pinView = (MKPinAnnotationView*)view;
        pinView.pinColor = MKPinAnnotationColorGreen;
        PlaceAnnotation * annotation = (PlaceAnnotation*)view.annotation;
        int row = [placesTable getPlaceIndex:annotation.place];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        if (annotation.directCall){
            annotation.directCall = false;
        } else {
            //[placesTable tableView:nil willSelectRowAtIndexPath:indexPath];
            [placesTable.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            //[placesTable tableView:nil didSelectRowAtIndexPath:indexPath];
            
            PlaceModel * place = annotation.place;
            float mapRange = [self mapRangeForDistance:place.distance];
            [mapView setRegion:[mapView regionThatFits:MKCoordinateRegionMakeWithDistance([AppModel instance].ownLocation.coordinate, 2*mapRange, 2*mapRange)] animated:YES];
        }
        [self reorderAnnotationViews:[self getAnnotationViews]];
    }
}

- (void)mapView:(MKMapView *)_mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (view.annotation != _mapView.userLocation){
        MKPinAnnotationView * pinView = (MKPinAnnotationView*)view;
        pinView.pinColor = MKPinAnnotationColorRed;
        PlaceAnnotation * annotation = (PlaceAnnotation*)view.annotation;
        int row = [placesTable getPlaceIndex:annotation.place];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        [placesTable.tableView deselectRowAtIndexPath:indexPath animated:NO];
        //[placesTable tableView:nil didDeselectRowAtIndexPath:indexPath];
        [self reorderAnnotationViews:[self getAnnotationViews]];
    }
}

#pragma mark - LocationManager handler

- (void)locationManagerUpdate:(NSNotification*)notification
{
    bool firstUpdate = false;
    if ([AppModel instance].ownLocation == nil){
        firstUpdate = true;
    }
    [AppModel instance].ownLocation = [[LocationManager instance] location];
    if (firstUpdate){
        NSLog(@"location found %@", [[LocationManager instance] location]);
        lastLocationReload = [[AppModel instance].ownLocation retain];
        [self loadNavigate];
        if ([AppModel instance].role == ROLE_ADMIN){
            [self loadVenues];
        }
        float mapRange = MAP_SCALE*DEFAULT_MAP_RANGE;
        [mapView setRegion:MKCoordinateRegionMakeWithDistance([AppModel instance].ownLocation.coordinate, 2*mapRange, 2*mapRange)];
    } else {
        [self reloadTableLimited];
    }
}

- (void)locationManagerHeading:(NSNotification*)notification
{
    [AppModel instance].ownHeading = [[LocationManager instance] heading];
    [self reloadTableLimited];
    if ([self mapViewVisible]){
        
        float mapRotation = -toRadian([[AppModel instance] getAvailableHeading]);
        //[UIView beginAnimations:nil context:NULL];
        //[UIView setAnimationDuration:0.1];
        [mapView setTransform:CGAffineTransformMakeRotation(mapRotation)];
        //[UIView commitAnimations];
        
        NSMutableArray * annotationViews = [[NSMutableArray alloc] initWithCapacity:mapView.annotations.count];
        bool shouldReorder = true;
        for (id annotation in mapView.annotations) {
            MKAnnotationView *annotationView = [mapView viewForAnnotation:annotation]; 
            if (annotationView == nil){
                //shouldReorder = false;
            } else {
                [annotationView setTransform:CGAffineTransformMakeRotation(-mapRotation)];
                [annotationViews addObject:annotationView];
            }
        }
        
        NSTimeInterval now = CFAbsoluteTimeGetCurrent();
        if (shouldReorder && now - lastReorderAnnotation > ANNOTATION_REORDER_INTERVAL){// && abs(mapRotation - lastReorderRotation) > 0.1f){
            [self reorderAnnotationViews:annotationViews];
        }
        [annotationViews release];

    }

}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    lastTableReload = 0;
    lastTableSort = 0;
    lastReorderAnnotation = 0;
    lastReorderRotation = -100;
    loadingVenues = false;
    loadingNavigate = false;
    [LocationManager instance];
    
    [[LocationManager instance] addSubscriber:self updateHandler:@selector(locationManagerUpdate:) headingHandler:@selector(locationManagerHeading:)];
    [AppModel instance].ownLocation = [[LocationManager instance] location];    
    //[PlacesManager instance].delegate = self;
    
    navigateAnnotations = [[NSMutableArray alloc] init];
    venuesAnnotations = [[NSMutableArray alloc] init];
    float mapWidth = self.view.frame.size.width;
    float mapHeight = containerTable.bounds.size.height - MAP_OFFSET_BOTTOM;
    
    //add TableViewController
    PlacesTableViewController * viewController = [[PlacesTableViewController alloc] init];
    viewController.delegate = self;
    CGRect tableFrame = containerTable.bounds;
    viewController.view.frame = tableFrame;
    containerTable.clipsToBounds = true;
    [containerTable addSubview:viewController.view];
    self.placesTable = viewController;
    placesTable.tableView.clipsToBounds = false;
    [viewController release];
    
    if ([AppModel instance].role == ROLE_ADMIN){
        [tabBar setSelectedItem:[tabBar.items objectAtIndex:0]];
        [self showTabNavigate];    
    } else {
        [tabBar setItems:[NSArray array] animated:NO];
        [self showTabNavigate];    
    }
    
    UIScrollView * containerMapView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -mapHeight, mapWidth, mapHeight)];
    containerMapView.contentSize = CGSizeMake(containerMapView.frame.size.width, containerMapView.frame.size.height);
    containerMapView.showsVerticalScrollIndicator = false;
    containerMapView.bounces = true;
    containerMapView.alwaysBounceVertical = true;
    containerMapView.clipsToBounds = false;
    containerMapView.scrollsToTop = NO;
    containerMapView.delegate = placesTable;
    UIView * blackBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.frame.size.height, mapWidth, self.view.frame.size.height)];
    blackBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [containerMapView addSubview:blackBackground];
    [blackBackground release];
    
    //mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mapHeight)];
    float mapDiagonal = sqrt(mapWidth*mapWidth + mapHeight*mapHeight);
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, mapDiagonal, mapDiagonal)];
    //mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, mapWidth*MAP_SCALE, mapHeight*MAP_SCALE)];
    mapView.scrollEnabled = false;
    mapView.zoomEnabled = true;
    [mapView setShowsUserLocation:YES];
    mapView.delegate = self;
    //NSLog(@"%@", mapView.gestureRecognizers);
    
    CenterMapViewGestureRecognizer * gestureRecognizer = [[CenterMapViewGestureRecognizer alloc] initWithMapView:mapView];
    centerMapViewGestureRecognizer = gestureRecognizer;
    [mapView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    UIView * maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mapWidth, mapHeight)];
    maskView.clipsToBounds = true;
    //maskView.backgroundColor = [UIColor colorWithRed:180.f/256.f green:178.f/256.f blue:173.f/256.f alpha:1];
    [maskView addSubview:mapView];
    mapView.center = CGPointMake(mapWidth/2, mapHeight/2 - maskView.frame.origin.y);
    //place google logo
    UIImageView * googleImage;
    for(UIView *v in mapView.subviews) {        
        if([v isKindOfClass:[UIImageView class]]) {
            v.hidden = YES;
            googleImage=((UIImageView *)v);
            break;
        }
    }
    UIImageView * googleLogo = [[UIImageView alloc] initWithImage:googleImage.image];
    googleLogo.frame = CGRectMake(googleImage.frame.origin.x, maskView.frame.size.height - 30, googleImage.frame.size.width, googleImage.frame.size.height);
    [maskView addSubview:googleLogo];
    
    [containerMapView addSubview:maskView];
    [maskView release];
    
    placesTable.mapView = containerMapView;
    [placesTable.tableView addSubview:containerMapView];
    
    //schedule reload data
    [NSTimer scheduledTimerWithTimeInterval:DATA_RELOAD_INTERVAL target:self selector:@selector(reloadNavigateAndVenues:) userInfo:nil repeats:YES];
    
    UITapGestureRecognizer * tripleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tripleTapGestureHandler:)];
    tripleTapGestureRecognizer.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:tripleTapGestureRecognizer];
    [tripleTapGestureRecognizer release];
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
