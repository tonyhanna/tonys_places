//
//  PlacesManager.h
//  tonyplaces
//
//  Created by Senja iMac on 5/31/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Foursquare.h"
#import "BatchURLLoader.h"
#import "AppModel.h"

enum {
    LOGIN_WRONG = 1,
    LOGIN_OK,
    LOGIN_EXPIRED,
    REQUEST_PENDING,
    REQUEST_ACCEPTED,
    REQUEST_REJECTED
};

@class PlaceModel;

@interface PlacesManager : NSObject<FoursquareDelegate, BatchURLLoaderDelegate> {
    id delegate;
    NSString * foursquareId;
    NSString * foursquareName;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSString * foursquareId;
@property (nonatomic,retain) NSString * foursquareName;

+ (PlacesManager*)instance;
- (void)checkDeviceAccess;
- (BOOL)isLoggedInFoursquare;
- (void)loginFoursquare:(NSString*)username password:(NSString*)password;
- (void)checkAccess;
- (void)loadNavigate:(CLLocation*)ownLocation;
- (void)loadVenues:(CLLocation*)ownLocation withSearchTags:(NSArray*)searchTags;
- (void)addVenue:(PlaceModel*)place;
- (void)removeVenue:(PlaceModel*)place;

@end

@protocol PlacesManagerDelegate<NSObject>

@optional
- (void)placesManagerCheckDeviceAccess:(NSNumber*)role;
@optional
- (void)placesManagerLoginFoursquare:(NSNumber*)status;
@optional
- (void)placesManagerCheckAccess:(NSNumber*)status;
@optional 
- (void)placesManagerLoadNavigate:(NSArray*)places;
@optional 
- (void)placesManagerLoadVenues:(NSArray*)places;
@optional
- (void)placesManagerAddVenue:(PlaceModel*)addedVenue;
@optional
- (void)placesManagerRemoveVenue:(NSNumber*)success;

@end