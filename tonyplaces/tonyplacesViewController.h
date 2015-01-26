//
//  tonyplacesViewController.h
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/27/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PlacesManager.h"
#import "PlacesTableViewController.h"

@class CenterMapViewGestureRecognizer;

@interface tonyplacesViewController : UIViewController<UITabBarDelegate,PlacesTableViewControllerDelegate,MKMapViewDelegate> {
    UITabBar * tabBar;
    UIView * containerTable;
    
    PlacesTableViewController * placesTable;
    MKMapView * mapView;
    
    NSMutableDictionary * navigateIds;
    NSMutableArray * navigateData;
    NSMutableArray * venuesData;
    NSMutableArray * navigateAnnotations;
    NSMutableArray * venuesAnnotations;
    
    int tabSelected;
    CFTimeInterval lastTableReload;
    CFTimeInterval lastTableSort;
    CLLocation * lastLocationReload;
    CFTimeInterval lastReorderAnnotation;
    float lastReorderRotation;
    
    bool loadingNavigate;
    bool loadingVenues;
    
    CenterMapViewGestureRecognizer * centerMapViewGestureRecognizer;

}

@property (nonatomic,retain) IBOutlet UITabBar * tabBar;
@property (nonatomic,retain) IBOutlet UIView * containerTable;

@property (nonatomic,retain) PlacesTableViewController * placesTable;

- (void)loadVenues;
- (void)setNavigateData:(NSArray*)places;
- (void)addNavigateData:(PlaceModel*)place;
- (void)setVenuesData:(NSArray*)places;
                        

@end

@interface MKAnnotationView (Sorting)
- (NSComparisonResult)compareCenterY:(MKAnnotationView*)view;
@end
