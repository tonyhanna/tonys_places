//
//  CenterMapViewGestureRecognizer.h
//  tonyplaces
//
//  Created by Senja iMac on 6/24/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CenterMapViewGestureRecognizer : UIGestureRecognizer {
    NSTimer * centeringDelayTimer;
}

- (id)initWithMapView:(MKMapView *)mapView;

@property (nonatomic,retain) MKMapView * mapView;
@property (nonatomic,assign) BOOL isTouchEnded;
@property (nonatomic,assign) BOOL isMapAnimating;

@end
