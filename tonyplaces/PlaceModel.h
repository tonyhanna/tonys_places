//
//  PlaceModel.h
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/30/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceModel : NSObject {
    NSString * venueId;
    NSString * name;
    NSArray * categories;
    NSString * description;
    bool verified;
    NSString * phone;
    NSString * twitter;
    
    NSString * address;
    NSString * crossStreet;
    NSString * city;
    NSString * state;
    NSString * postalCode;
    NSString * country;
    
    double latitude;
    double longitude;
    double distance;
    double bearing;
    bool addedNavigate;
}

@property (nonatomic,retain) NSString * venueId;
@property (nonatomic,retain) NSString * name;
@property (nonatomic,retain) NSArray * categories;
@property (nonatomic,retain) NSString * description;
@property (nonatomic,assign) bool verified;
@property (nonatomic,retain) NSString * phone;
@property (nonatomic,retain) NSString * twitter;

@property (nonatomic,retain) NSString * address;
@property (nonatomic,retain) NSString * crossStreet;
@property (nonatomic,retain) NSString * city;
@property (nonatomic,retain) NSString * state;
@property (nonatomic,retain) NSString * postalCode;
@property (nonatomic,retain) NSString * country;

@property (nonatomic,assign) double latitude;
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double distance;
@property (nonatomic,assign) double bearing;
@property (nonatomic,assign) bool addedNavigate;

- (NSString*)makeAddQuery;
- (NSString*)categoriesAsString;
- (void)setCategoriesWithString:(NSString*)aString;

@end
