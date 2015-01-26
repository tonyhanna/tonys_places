//
//  LocationHelper.h
//  tonyplaces
//
//  Created by Senja iMac on 6/1/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject {
    
}

/** return bearing in degrees */
+ (double)calculateBearingFrom:(CLLocationCoordinate2D)loc1 to:(CLLocationCoordinate2D)loc2;

@end
