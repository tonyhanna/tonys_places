//
//  CenterMapViewGestureRecognizer.m
//  tonyplaces
//
//  Created by Senja iMac on 6/24/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "CenterMapViewGestureRecognizer.h"
#import "AppModel.h"

@implementation CenterMapViewGestureRecognizer

@synthesize mapView, isTouchEnded, isMapAnimating;

- (id)initWithMapView:(MKMapView *)_mapView {
    self = [super init];
    if (self) {
        self.mapView = _mapView;
    }
    
    return self;
}

- (BOOL)canBePreventedByGestureRecognizer:
(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touch end");
    CLLocation *location = [AppModel instance].ownLocation;
    if (location != nil){
        if (centeringDelayTimer){
            [centeringDelayTimer invalidate];
            [centeringDelayTimer release];
        }
        centeringDelayTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(centeringLocation:) userInfo:nil repeats:NO] retain];
    }
}

- (void)centeringLocation:(NSTimer*)timer
{
    [timer invalidate];
    [centeringDelayTimer release];
    centeringDelayTimer = nil;
    //NSLog(@"%f", mapView.region.span.longitudeDelta);
    if (mapView.region.span.longitudeDelta < 2.5f){
        [UIView setAnimationsEnabled:YES];
        [mapView setCenterCoordinate:[AppModel instance].ownLocation.coordinate animated:YES];
    }
}


@end
