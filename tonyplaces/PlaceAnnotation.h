//
//  PlaceAnnotation.h
//  tonyplaces
//
//  Created by Senja iMac on 6/9/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PlaceModel;

@interface PlaceAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    PlaceModel * place;
    bool directCall;
}

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) PlaceModel * place;
@property (nonatomic,assign) bool directCall;

@end
