//
//  MathUtil.h
//  tonyplaces
//
//  Created by Senja iMac on 6/1/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define toDegree(radians) ((radians) * (180.0 / M_PI))
#define toRadian(angle) ((angle) / 180.0 * M_PI)
#define sinD(x) (sin(toRadian(x)))
#define cosD(x) (cos(toRadian(x)))
#define tanD(x) (tan(toRadian(x)))

@interface MathUtil : NSObject {
    
}

@end
