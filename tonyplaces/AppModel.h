//
//  AppModel.h
//  tonyplaces
//
//  Created by Senja iMac on 6/1/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define TABLE_UPDATE_INTERVAL (0.15)
#define TABLE_RESORT_INTERVAL (5.f)
#define ANNOTATION_REORDER_INTERVAL (1.f)
#define MAP_OFFSET_BOTTOM (2*82+1)
#define MAP_SCALE (1.7f)
#define DEFAULT_MAP_RANGE (1000.f)
#define NAVIGATE_RADIUS (10000.f)
#define DATA_RELOAD_DISTANCE (1000.f)
#define DATA_RELOAD_INTERVAL (30.f)

enum {
    tabNavigate = 1, tabAddVenue
};

enum {
    stateLogin = 1, stateLocation, stateThankYou, stateStillReviewing
};

enum {
    ROLE_ADMIN = 1,
    ROLE_PUBLIC
};

@interface AppModel : NSObject {
    int role;
    NSDictionary * config;
    NSArray * searchTags;
    CLLocation * ownLocation;
    CLHeading * ownHeading;
    bool autoLogin;
    
    id delegate;
}

@property (nonatomic,assign) int role;
@property (nonatomic,readonly) NSDictionary * config;
@property (nonatomic,readonly) NSArray * searchTags;
@property (nonatomic,retain) CLLocation * ownLocation;
@property (nonatomic,retain) CLHeading * ownHeading;
@property (nonatomic,assign) bool autoLogin;

@property (nonatomic,retain) id delegate;

+ (AppModel*)instance;
- (CLLocationDirection)getAvailableHeading;
- (void)loadPreferences;

@end

@protocol AppModelDelegate <NSObject>

@optional
- (void)appModelSearchTagsChanged;

@end
