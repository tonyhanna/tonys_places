//
//  LocationHelper.m
//  tonyplaces
//
//  Created by Senja iMac on 6/1/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "LocationHelper.h"
#import "MathUtil.h"


@implementation LocationHelper

+ (double)calculateBearingFrom:(CLLocationCoordinate2D)loc1 to:(CLLocationCoordinate2D)loc2
{
    double dLong = toRadian(loc2.longitude - loc1.longitude);
    return toDegree(atan2(sin(dLong)*cosD(loc2.latitude), cosD(loc1.latitude)*sinD(loc2.latitude) - sinD(loc1.latitude)*cosD(loc2.latitude)*cos(dLong)));
}

@end
